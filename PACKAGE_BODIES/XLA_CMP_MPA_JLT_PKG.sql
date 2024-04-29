--------------------------------------------------------
--  DDL for Package Body XLA_CMP_MPA_JLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_MPA_JLT_PKG" AS
/* $Header: xlacpmlt.pkb 120.8 2007/05/04 00:21:20 masada ship $   */
/*============================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                      |
|                       Redwood Shores, CA, USA                               |
|                         All rights reserved.                                |
+=============================================================================+
| PACKAGE NAME                                                                |
|     xla_cmp_mpa_jlt_pkg                                                     |
|                                                                             |
| DESCRIPTION                                                                 |
|     This is a XLA private package, which contains all the logic required    |
|     to generate Recognition Accounting line type procedures from AMB        |
|     specifications.                                                         |
|                                                                             |
|                                                                             |
| HISTORY                                                                     |
|     11-Jul-2005 A.Wan       Created for MPA project                         |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria            |
|     30-Jan-2006 A.Wan       Bug 4655713 - in GenerateCallADR, process       |
|                                           ALL segments first                |
|     02-Feb-2006 A.Wan       Bug 4655713b - handle MPA with bflow method     |
|     13-Feb-2006 A.Wan       Bug 4955764  - set g_rec_lines.array_gl_date.   |
|     16-Apr-2006 A.Wan       Bug 5132303  - Gain/Loss change for bflow.      |
+============================================================================*/
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Constants                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+


C_RECOG_JLT_BODY   CONSTANT      VARCHAR2(10000):= '
---------------------------------------
--
-- PRIVATE FUNCTION
--         RecognitionJLT_$alt_hash_id$
--
---------------------------------------
FUNCTION RecognitionJLT_$alt_hash_id$ (
  p_application_id         INTEGER
 ,p_event_id               INTEGER
 ,p_hdr_idx                INTEGER
 ,p_period_num             INTEGER
 ,p_rec_acct_attrs         XLA_AE_LINES_PKG.t_rec_acct_attrs
 ,p_calculate_acctd_flag   VARCHAR2
 ,p_calculate_g_l_flag     VARCHAR2
 ,p_bflow_applied_to_amt   NUMBER   -- 5132302
 $parameters$
) RETURN INTEGER
   IS
   l_component_type              VARCHAR2(80)  ;
   l_component_code              VARCHAR2(30)  ;
   l_component_type_code         VARCHAR2(1)   ;
   l_component_appl_id           INTEGER       ;
   l_amb_context_code            VARCHAR2(30)  ;
   l_entity_code                 VARCHAR2(30)  ;
   l_event_class_code            VARCHAR2(30)  ;
   l_ae_header_id                NUMBER        ;
   l_event_type_code             VARCHAR2(30)  ;
   l_line_definition_code        VARCHAR2(30)  ;
   l_line_definition_owner_code  VARCHAR2(1)   ;
   l_accrual_jlt_type_code       VARCHAR2(1)   ;
   l_accrual_jlt_code            VARCHAR2(30)  ;
   l_balance_type_code           VARCHAR2(1)   ;
   l_acc_rev_natural_side_code   VARCHAR2(1)   ;
   l_segment                     VARCHAR2(30)  ;
   l_ccid                        NUMBER;
   l_adr_transaction_coa_id      NUMBER ;
   l_adr_accounting_coa_id       NUMBER ;
   l_adr_value_type_code         VARCHAR2(30);
   l_adr_value_segment_code      VARCHAR2(30);
   l_adr_flexfield_segment_code  VARCHAR2(30);
   l_adr_flex_value_set_id       NUMBER ;
   l_adr_value_combination_id    NUMBER ;

   l_bflow_method_code           VARCHAR2(30); -- 4655713b
   l_inherit_desc_flag           VARCHAR2(1);  -- 4655713b

   l_CreateCcid                  BOOLEAN       := TRUE;
   l_log_module                  VARCHAR2(240);
   --
BEGIN
   --
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||''.RecognitionJLT_$alt_hash_id$'';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''BEGIN of RecognitionJLT_$alt_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;
   --
   l_component_type             := ''AMB_RECOGNITION_JLT'';
   l_component_appl_id          :=   $mpa_jlt_appl_id$;
   l_component_type_code        := ''$mpa_jlt_type_code$'';
   l_component_code             := ''$mpa_jlt_code$'';
   l_amb_context_code           := ''$amb_context_code$'';
   l_entity_code                := ''$entity_code$'';
   l_event_class_code           := ''$event_class_code$'';
   l_event_type_code            := ''$event_type_code$'';
   l_line_definition_owner_code := ''$line_definition_owner_code$'';
   l_line_definition_code       := ''$line_definition_code$'';
   l_accrual_jlt_type_code      := ''$jlt_type_code$'';
   l_accrual_jlt_code           := ''$jlt_code$'';
   --
   l_balance_type_code          := ''A'';

   l_segment                    := NULL;
   l_ccid                       := NULL;
   l_adr_transaction_coa_id     := NULL;
   l_adr_accounting_coa_id      := NULL;
   l_adr_value_type_code        := NULL;
   l_adr_value_segment_code     := NULL;
   l_adr_flexfield_segment_code := NULL;
   l_adr_flex_value_set_id      := NULL;
   l_adr_value_combination_id   := NULL;

   l_bflow_method_code          := ''$bflow_method_code$'';   -- 4655713b
   l_inherit_desc_flag          := ''$inherit_desc_flag$'';   -- 4655713b

   XLA_AE_LINES_PKG.SetNewLine;
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id      -- p_hdr_idx
                                     ,p_header_num   => p_period_num);
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


   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;
   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber)
                                                    := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;
   --
   -- set accounting attributes for the line type
   --
   XLA_AE_LINES_PKG.SetLineAcctAttrs(p_rec_acct_attrs);

   -- 4655713b to handle MPA with Business flow method
   XLA_AE_LINES_PKG.g_rec_lines.array_inherit_desc_flag(XLA_AE_LINES_PKG.g_LineNumber):= l_inherit_desc_flag;
   IF l_bflow_method_code <> ''NONE'' THEN
      XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT(''MPA_'',l_bflow_method_code);
      IF l_inherit_desc_flag = ''Y'' THEN
         XLA_AE_LINES_PKG.g_rec_lines.array_description(XLA_AE_LINES_PKG.g_LineNumber):= NULL;
      END IF;
   END IF;

   -- 5132302
   XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber):= p_bflow_applied_to_amt;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
                                  XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(p_hdr_idx);

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
   --
   $call_adr$
   --
   --
   XLA_AE_LINES_PKG.ValidateCurrentLine;

   ------------------------------------------------------------
   -- Add this to calculate the recognition amounts
   ------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   --
   -- following update the status on header depending on the erros encountered
   -- while creating the line
   --
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
          (p_hdr_idx           => p_hdr_idx
          ,p_balance_type_code => ''A'');
    --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''END of RecognitionJLT_$alt_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   --
   RETURN XLA_AE_LINES_PKG.g_LineNumber;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => ''ERROR: XLA_CMP_COMPILER_ERROR=''||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RAISE;
   WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => ''$package_name$.RecognitionJLT_$alt_hash_id$'');
END RecognitionJLT_$alt_hash_id$;
--
';  -- C_RECOG_JLT_BODY


--+==========================================================================+
--|                                                                          |
--| Private global constant declarations                                     |
--|                                                                          |
--+==========================================================================+
--
--
g_package_name     VARCHAR2(30);  -- initialise in GenerateMpaJLT and used by GenerateOneMpaJLT

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_CMP_MPA_JLT_PKG';

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
             (p_location   => 'XLA_CMP_MPA_JLT_PKG.trace');
END trace;




/*------------------------------------------------------------+
|                                                             |
|  PrivateFunction                                            |
|                                                             |
|       GenerateCallADR                                       |
|                                                             |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GenerateCallADR(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
--
, p_accrual_jlt_type_code        IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
, p_mpa_jlt_type_code            IN VARCHAR2
, p_mpa_jlt_code                 IN VARCHAR2
, p_bflow_method_code            IN VARCHAR2  -- 4655713
--
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_array_mpa_jlt_source_index   IN OUT NOCOPY xla_cmp_source_pkg.t_array_byInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN  CLOB
IS
CURSOR adr_cur IS
SELECT DISTINCT
        NVL(xldj.segment_rule_appl_id,xldj.application_id)
      , xldj.segment_rule_type_code
      , xldj.segment_rule_code
      , xldj.flexfield_segment_code
      , 'NA'                          -- 'Side' is not applicable
      , xldj.inherit_adr_flag
      , xld.accounting_coa_id
      , xld.transaction_coa_id
  FROM  xla_mpa_jlt_adr_assgns      xldj
      , xla_line_definitions_b      xld
 WHERE xldj.application_id                = p_application_id
   AND xldj.amb_context_code              = p_amb_context_code
   AND xldj.event_class_code              = p_event_class_code
   AND xldj.event_type_code               = p_event_type_code
   AND xldj.line_definition_owner_code    = p_line_definition_owner_code
   AND xldj.line_definition_code          = p_line_definition_code
   AND xldj.accounting_line_type_code     = p_accrual_jlt_type_code
   AND xldj.accounting_line_code          = p_accrual_jlt_code
   AND xldj.mpa_accounting_line_type_code = p_mpa_jlt_type_code
   AND xldj.mpa_accounting_line_code      = p_mpa_jlt_code
--
   AND xld.application_id                  = xldj.application_id
   AND xld.amb_context_code                = xldj.amb_context_code
   AND xld.event_class_code                = xldj.event_class_code
   AND xld.event_type_code                 = xldj.event_type_code
   AND xld.line_definition_owner_code      = xldj.line_definition_owner_code
   AND xld.line_definition_code            = xldj.line_definition_code
--
ORDER BY decode(xldj.FLEXFIELD_SEGMENT_CODE,'ALL',1,2),                       -- 4655713  process ALL segments first
         xldj.segment_rule_code
;

l_array_adr_type_code           xla_cmp_source_pkg.t_array_VL1;
l_array_adr_code                xla_cmp_source_pkg.t_array_VL30;
l_array_adr_segment_code        xla_cmp_source_pkg.t_array_VL30;
l_array_side_code               xla_cmp_source_pkg.t_array_VL30;
l_array_adr_appl_id             xla_cmp_source_pkg.t_array_NUM;
l_array_inherit_adr_flag        xla_cmp_source_pkg.t_array_VL1;
l_array_accounting_coa_id       xla_cmp_source_pkg.t_array_NUM;
l_array_transaction_coa_id      xla_cmp_source_pkg.t_array_NUM;

l_adrs                          CLOB;
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
--

OPEN adr_cur;
FETCH adr_cur BULK COLLECT INTO    l_array_adr_appl_id
                                 , l_array_adr_type_code
                                 , l_array_adr_code
                                 , l_array_adr_segment_code
                                 , l_array_side_code
                                 , l_array_inherit_adr_flag
                                 , l_array_accounting_coa_id
                                 , l_array_transaction_coa_id
                                 ;
CLOSE adr_cur;

l_adrs :=  xla_cmp_acct_line_type_pkg.GenerateADRCalls(
                    p_application_id
                   ,p_entity_code
                   ,p_event_class_code
                   ,l_array_adr_type_code
                   ,l_array_adr_code
                   ,l_array_adr_segment_code
                   ,l_array_side_code             -- Side Code Not Applicable
                   ,l_array_adr_appl_id           -- IN
                   ,l_array_inherit_adr_flag      -- IN
                   ,p_bflow_method_code           -- 4655713
                   ,l_array_accounting_coa_id     -- IN
                   ,l_array_transaction_coa_id    -- IN
                   ,p_array_mpa_jlt_source_index  -- IN OUT
                   ,p_rec_aad_objects
                   ,p_rec_sources);
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
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
     END IF;
     RETURN NULL;
  WHEN OTHERS THEN
     IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
     xla_exceptions_pkg.raise_message
         (p_location => 'XLA_CMP_MPA_JLT_PKG.GenerateCallADR');

END GenerateCallADR;



/*------------------------------------------------------------+
|                                                             |
|  PrivateFunction                                            |
|                                                             |
|       GenerateOneMpaJLT                                     |
|                                                             |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GenerateOneMpaJLT(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
--
, p_accrual_jlt_owner_code       IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
--
, p_mpa_jlt_owner_code           IN VARCHAR2
, p_mpa_jlt_code                 IN VARCHAR2
, p_mpa_jlt_name                 IN VARCHAR2
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
, p_bflow_method_code            IN VARCHAR2  -- 4655713
, p_inherit_desc_flag            IN VARCHAR2  -- 4655713b
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--
l_parameters       VARCHAR2(32000);

l_jlt              CLOB;
l_ObjectIndex      BINARY_INTEGER;
l_array_jlt        DBMS_SQL.VARCHAR2S;

l_array_mpa_jlt_source_index    xla_cmp_source_pkg.t_array_ByInt;
l_array_null_mpa_jlt_src_idx    xla_cmp_source_pkg.t_array_ByInt;
l_log_module                    VARCHAR2(240);

BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateOneMpaJLT';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateOneMpaJLT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

--------------------------------------
-- Initialise
--------------------------------------
p_IsCompiled  := FALSE;
--
--
-- Replace JLT information token
--
l_jlt := C_RECOG_JLT_BODY;
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$mpa_jlt_appl_id$'            ,TO_CHAR(p_application_id));
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$mpa_jlt_type_code$'          ,p_mpa_jlt_owner_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$mpa_jlt_code$'               ,p_mpa_jlt_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$amb_context_code$'           ,p_amb_context_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$entity_code$'                ,p_entity_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$event_class_code$'           ,p_event_class_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$event_type_code$'            ,p_event_type_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$line_definition_owner_code$' ,p_line_definition_owner_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$line_definition_code$'       ,p_line_definition_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$jlt_type_code$'              ,p_accrual_jlt_owner_code);
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$jlt_code$'                   ,p_accrual_jlt_code);

l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$bflow_method_code$'          ,p_bflow_method_code);  -- 4655713b
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt ,'$inherit_desc_flag$'          ,p_inherit_desc_flag);  -- 4655713b

l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$acct_line_options$'
                ,xla_cmp_acct_line_type_pkg.GetALTOption
                   (p_acct_entry_type_code
                   ,'C'  -- mpa line is not gain/loss for sure
                   ,p_natural_side_code
                   ,p_transfer_mode_code
                   ,p_switch_side_flag
                   ,p_merge_duplicate_code)
                );
--
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$set_acct_class$'
                ,xla_cmp_acct_line_type_pkg.GetAcctClassCode
                   (p_accounting_class_code)
                );
--
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$set_rounding_class$'
                , xla_cmp_acct_line_type_pkg.GetRoundingClassCode
                   (p_rounding_class_code)
                );

l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$call_analytical_criteria$'
                ,xla_cmp_analytic_criteria_pkg.GenerateMpaLineAC
                  (p_application_id
                  ,p_amb_context_code
                  ,p_event_class_code
                  ,p_event_type_code
                  ,p_line_definition_owner_code
                  ,p_line_definition_code
                  ,p_accrual_jlt_owner_code
                  ,p_accrual_jlt_code
                  ,p_mpa_jlt_owner_code
                  ,p_mpa_jlt_code
                  ,l_array_mpa_jlt_source_index
                  ,p_rec_sources)
               );

--
IF p_description_type_code IS NOT NULL AND
   p_description_code      IS NOT NULL THEN
  l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$call_description$'
                , xla_cmp_acct_line_type_pkg.GenerateCallDescription
                   (p_application_id         => p_application_id
                   ,p_description_type_code  => p_description_type_code
                   ,p_description_code       => p_description_code
                   ,p_header_line            => 'L'                        -- line
                   ,p_array_alt_source_index => l_array_mpa_jlt_source_index
                   ,p_rec_aad_objects        => p_rec_aad_objects
                   ,p_rec_sources            => p_rec_sources)
                );
  --
ELSE
  l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$call_description$'
                ,'-- no description for the jlt');
END IF;

l_jlt := xla_cmp_string_pkg.replace_token(l_jlt
                ,'$call_adr$'
                ,GenerateCallADR       -- from XLA_CMP_MPA_JLT_PKG
                   (p_application_id
                   ,p_amb_context_code
                   ,p_entity_code
                   ,p_event_class_code
                   ,p_event_type_code
                   ,p_line_definition_owner_code
                   ,p_line_definition_code
                   ,p_accrual_jlt_owner_code
                   ,p_accrual_jlt_code
                   ,p_mpa_jlt_owner_code
                   ,p_mpa_jlt_code
                   ,p_bflow_method_code        -- 4655713
                   ,p_rec_aad_objects
                   ,l_array_mpa_jlt_source_index   -- IN OUT
                   ,p_rec_sources)
                );
--
l_parameters := xla_cmp_source_pkg.GenerateParameters(
              p_array_source_index    => l_array_mpa_jlt_source_index
            , p_rec_sources           => p_rec_sources
            ) ;
--
IF l_parameters IS NULL THEN
  l_jlt := xla_cmp_string_pkg.replace_token(l_jlt, '$parameters$' ,' ');
ELSE
  l_jlt := xla_cmp_string_pkg.replace_token(l_jlt, '$parameters$', l_parameters );
END IF;

--

l_ObjectIndex := xla_cmp_source_pkg.CacheAADObject (
               p_object                      => xla_cmp_source_pkg.C_RECOG_JLT
             , p_object_code                 => p_mpa_jlt_code
             , p_object_type_code            => p_mpa_jlt_owner_code
             , p_application_id              => p_application_id
             , p_event_class_code            => p_event_class_code
             , p_event_type_code             => p_event_type_code
             , p_line_definition_owner_code  => p_line_definition_owner_code
             , p_line_definition_code        => p_line_definition_code
             , p_array_source_index          => l_array_mpa_jlt_source_index
             , p_rec_aad_objects             => p_rec_aad_objects
             --
);
--

l_jlt := xla_cmp_string_pkg.replace_token(l_jlt, '$alt_hash_id$', TO_CHAR(l_ObjectIndex));
l_jlt := xla_cmp_string_pkg.replace_token(l_jlt, '$package_name$', g_package_name);

xla_cmp_string_pkg.CreateString(
                      p_package_text  => l_jlt
                     ,p_array_string  => l_array_jlt
                     );

p_IsCompiled := TRUE;    -- l_IsCompiled ;

--l_array_mpa_jlt_source_index := l_array_null_mpa_jlt_src_idx; -- awan

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace
       (p_msg      => 'return value. = '||
            CASE p_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);

  trace
       (p_msg      => 'END of GenerateOneMpaJLT'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
END IF;

RETURN l_array_jlt;

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
         (p_location => 'XLA_CMP_MPA_JLT_PKG.GenerateOneMpaJLT');
END GenerateOneMpaJLT;



/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateMpaJLCProcs                                   |
|                                                             |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GenerateMpaJLTProcs(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--
-- Retrieve all recognition JLT
--
CURSOR jlt_cur
IS
SELECT  DISTINCT
        xmja.mpa_accounting_line_type_code
      , xmja.mpa_accounting_line_code
      --
      , REPLACE(xaltt.name , '''','''''')
      --
      , xmja.description_type_code
      , xmja.description_code
      --
      , xaltb.accounting_entry_type_code
      , CASE WHEN xmja.mpa_accounting_line_code      = xldj.accounting_line_code AND
                  xmja.mpa_accounting_line_type_code = xldj.accounting_line_type_code
             THEN DECODE(xaltb.natural_side_code,'D','C','D')
             ELSE xaltb.natural_side_code
             END
      , xaltb.gl_transfer_mode_code
      , xaltb.switch_side_flag
      , xaltb.merge_duplicate_code
      --
      , xaltb.accounting_class_code
      , xaltb.rounding_class_code
      --
      , xpah.entity_code
      , xpah.event_class_code
      , xpah.event_type_code
      --
      , xald.line_definition_owner_code
      , xald.line_definition_code
      --
      , xldj.accounting_line_type_code
      , xldj.accounting_line_code
      --
      , xaltb.business_method_code  -- 4655713
      , xmja.inherit_desc_flag      -- 4655713b
  FROM  xla_aad_line_defn_assgns  xald
      , xla_line_defn_jlt_assgns  xldj
      , xla_mpa_jlt_assgns        xmja
      , xla_prod_acct_headers     xpah
      , xla_acct_line_types_b     xaltb
      , xla_acct_line_types_tl    xaltt
      , xla_line_definitions_b    xld
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
   AND  xmja.application_id              = xldj.application_id
   AND  xmja.amb_context_code            = xldj.amb_context_code
   AND  xmja.event_class_code            = xldj.event_class_code
   AND  xmja.event_type_code             = xldj.event_type_code
   AND  xmja.line_definition_owner_code  = xldj.line_definition_owner_code
   AND  xmja.line_definition_code        = xldj.line_definition_code
   AND  xmja.accounting_line_code        = xldj.accounting_line_code
   AND  xmja.accounting_line_type_code   = xldj.accounting_line_type_code
   --
   AND  xaltb.application_id             = xmja.application_id
   AND  xaltb.amb_context_code           = xmja.amb_context_code
   AND  xaltb.accounting_line_code       = xmja.mpa_accounting_line_code
   AND  xaltb.accounting_line_type_code  = xmja.mpa_accounting_line_type_code
   AND  xaltb.event_class_code           = xmja.event_class_code
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
   AND xald.application_id         = xld.application_id
   AND xald.amb_context_code       = xld.amb_context_code
   AND xald.event_class_code       = xld.event_class_code
   AND xald.event_type_code        = xld.event_type_code
   AND xald.line_definition_owner_code = xld.line_definition_owner_code
   AND xald.line_definition_code  = xld.line_definition_code
   AND xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
   --
   --
 ORDER BY xldj.accounting_line_type_code, xldj.accounting_line_code,
          xmja.mpa_accounting_line_type_code, xmja.mpa_accounting_line_code
;
--
--
l_body                        DBMS_SQL.VARCHAR2S;
l_jlt                         DBMS_SQL.VARCHAR2S;
--
l_array_mpa_jlt_type_code     xla_cmp_source_pkg.t_array_VL1;
l_array_mpa_jlt_code          xla_cmp_source_pkg.t_array_VL30;
l_array_mpa_jlt_name          xla_cmp_source_pkg.t_array_VL80;
--
l_array_desc_type_code        xla_cmp_source_pkg.t_array_VL1;
l_array_desc_code             xla_cmp_source_pkg.t_array_VL30;
--
l_array_entry_type_code       xla_cmp_source_pkg.t_array_VL1;
l_array_natural_side_code     xla_cmp_source_pkg.t_array_VL1;
l_array_transfer_mode         xla_cmp_source_pkg.t_array_VL1;
l_array_switch_side_flag      xla_cmp_source_pkg.t_array_VL1;
l_array_merge_code            xla_cmp_source_pkg.t_array_VL1;
--
l_array_acct_class_code       xla_cmp_source_pkg.t_array_VL30;
l_array_rounding_class_code   xla_cmp_source_pkg.t_array_VL30;
--
l_array_entity_code           xla_cmp_source_pkg.t_array_VL30;
l_array_class_code            xla_cmp_source_pkg.t_array_VL30;
l_array_event_type            xla_cmp_source_pkg.t_array_VL30;
--
l_array_jld_owner_code        xla_cmp_source_pkg.t_array_VL1;
l_array_jld_code              xla_cmp_source_pkg.t_array_VL30;
--
l_array_accrual_jlt_type_code xla_cmp_source_pkg.t_array_VL1;
l_array_accrual_jlt_code      xla_cmp_source_pkg.t_array_VL30;
--
l_array_bflow_method_code     xla_cmp_source_pkg.t_array_VL30;  -- 4655713
l_array_inherit_desc_flag     xla_cmp_source_pkg.t_array_VL1;   -- 4655713b

--
l_IsCompiled                  BOOLEAN;
l_number                      NUMBER;

l_log_module                  VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateMpaJLTProcs';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateMpaJLTProcs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
OPEN  jlt_cur;
--
FETCH jlt_cur BULK COLLECT INTO   l_array_mpa_jlt_type_code
                                , l_array_mpa_jlt_code
                                , l_array_mpa_jlt_name
                                , l_array_desc_type_code
                                , l_array_desc_code
                                , l_array_entry_type_code
                                , l_array_natural_side_code
                                , l_array_transfer_mode
                                , l_array_switch_side_flag
                                , l_array_merge_code
                                , l_array_acct_class_code
                                , l_array_rounding_class_code
                                , l_array_entity_code
                                , l_array_class_code
                                , l_array_event_type
                                , l_array_jld_owner_code
                                , l_array_jld_code
                                , l_array_accrual_jlt_type_code
                                , l_array_accrual_jlt_code
                                , l_array_bflow_method_code   -- 4655713
                                , l_array_inherit_desc_flag   -- 4655713b
                                ;
CLOSE jlt_cur;
--
l_body := xla_cmp_string_pkg.g_null_varchar2s;

p_IsCompiled   := TRUE;

--
-- Generate RecognitionJLT_XX for each recognition JLT
--
IF l_array_mpa_jlt_code.COUNT > 0 THEN
  --
  p_IsCompiled   := TRUE;
  --
  FOR Idx In l_array_mpa_jlt_code.FIRST .. l_array_mpa_jlt_code.LAST LOOP
    --
    IF l_array_mpa_jlt_code.EXISTS(Idx) THEN
      --
      l_jlt := GenerateOneMpaJLT(
                 p_application_id             => p_application_id
               , p_amb_context_code           => p_amb_context_code
               , p_entity_code                => l_array_entity_code(Idx)
               , p_event_class_code           => l_array_class_code(Idx)
               , p_event_type_code            => l_array_event_type(Idx)
               , p_line_definition_owner_code => l_array_jld_owner_code(Idx)
               , p_line_definition_code       => l_array_jld_code(Idx)
               --
               , p_accrual_jlt_owner_code     => l_array_accrual_jlt_type_code(Idx)
               , p_accrual_jlt_code           => l_array_accrual_jlt_code(Idx)
               --
               , p_mpa_jlt_owner_code         => l_array_mpa_jlt_type_code(Idx)
               , p_mpa_jlt_code               => l_array_mpa_jlt_code(Idx)
               , p_mpa_jlt_name               => l_array_mpa_jlt_name(Idx)
               --
               , p_description_type_code      => l_array_desc_type_code(Idx)
               , p_description_code           => l_array_desc_code(Idx)
               , p_acct_entry_type_code       => l_array_entry_type_code(Idx)
               , p_natural_side_code          => l_array_natural_side_code(Idx)
               , p_transfer_mode_code         => l_array_transfer_mode(Idx)
               , p_switch_side_flag           => l_array_switch_side_flag(Idx)
               , p_merge_duplicate_code       => l_array_merge_code(Idx)
               , p_accounting_class_code      => l_array_acct_class_code(Idx)
               , p_rounding_class_code        => l_array_rounding_class_code(Idx)
               --
               , p_bflow_method_code          => l_array_bflow_method_code(Idx)  -- 4655713
               , p_inherit_desc_flag          => l_array_inherit_desc_flag(Idx)  -- 4655713b
               --
               , p_rec_aad_objects            => p_rec_aad_objects
               , p_rec_sources                => p_rec_sources
               , p_IsCompiled                 => l_IsCompiled
               );
      --
      l_body := xla_cmp_string_pkg.ConcatTwoStrings (
                                 p_array_string_1    => l_body
                                ,p_array_string_2    => l_jlt
                          );
      --
    END IF;
    --
    p_IsCompiled := p_IsCompiled AND l_IsCompiled;
  --
  END LOOP;
END IF;

RETURN l_body;

EXCEPTION
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
      (p_location => 'XLA_CMP_MPA_JLT_PKG.GenerateMpaJLTProcs');

END GenerateMpaJLTProcs;


/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateMpaJLT                                        |
|                                                             |
|  Generates the RecognitionJLT_xx() functions from the AMB   |
|  Recognition Journal line types assigned to the AAD.        |
|  It returns TRUE if generation succeeds, FALSE otherwise    |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GenerateMpaJLT(
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

l_IsCompiled  BOOLEAN;
l_body        DBMS_SQL.VARCHAR2S;
l_log_module                    VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateMpaJLT';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateMpaJLT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
-- Init global variables
--
l_IsCompiled     := TRUE;
l_body           := xla_cmp_string_pkg.g_null_varchar2s;
--
g_package_name   := p_package_name;
--
l_body  := GenerateMpaJLTProcs(
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
p_package_body := l_body;
g_package_name := NULL;
--
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
      (p_location => 'XLA_CMP_MPA_JLT_PKG.GenerateMpaJLT');
END GenerateMpaJLT;
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

END xla_cmp_mpa_jlt_pkg;

/
