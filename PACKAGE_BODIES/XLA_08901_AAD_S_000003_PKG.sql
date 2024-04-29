--------------------------------------------------------
--  DDL for Package Body XLA_08901_AAD_S_000003_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_08901_AAD_S_000003_PKG" AS
--
/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     XLA_08901_AAD_S_000003_PKG                                        |
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From Product Accounting Definition              |
|      Name    : Federal Financials AAD                                 |
|      Code    : FV_STANDARD_AAD                                        |
|      Owner   : PRODUCT                                                |
|      Version :                                                        |
|      AMB Context Code: DEFAULT                                        |
| HISTORY                                                               |
|     Generated at 28-08-2013 at 07:08:03 by user ANONYMOUS             |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_08901_AAD_S_000003_PKG';

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
             (p_location   => 'XLA_08901_AAD_S_000003_PKG.trace');
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.ValidateLookupMeaning');
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.GetMeaning');
END GetMeaning;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         Description_1
--
---------------------------------------
FUNCTION Description_1 (
  p_application_id      IN NUMBER
, p_ae_header_id        IN NUMBER DEFAULT NULL 
--FV_CHECK_NUMBER
 , p_source_1            IN NUMBER
--FV_CHECK_DATE
 , p_source_2            IN DATE
--FV_TREASURY_PAY_NUMBER
 , p_source_3            IN NUMBER
)
RETURN VARCHAR2
IS
l_component_type        VARCHAR2(80)   ;
l_component_code        VARCHAR2(30)   ;
l_component_type_code   VARCHAR2(1)    ;
l_component_appl_id     INTEGER        ;
l_amb_context_code      VARCHAR2(30)   ;
l_ledger_language       VARCHAR2(30)   ;
l_source                VARCHAR2(1996) ;
l_description           VARCHAR2(2000) ;
l_log_module            VARCHAR2(240)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Description_1';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of Description_1'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_ledger_language       := xla_ae_journal_entry_pkg.g_cache_ledgers_info.description_language;
l_component_type        := 'AMB_DESCRIPTION';
l_component_code        := 'FV_TREASURY_DESC';
l_component_type_code   := 'S';
l_component_appl_id     :=  8901;
l_amb_context_code      := 'DEFAULT';
l_source                := NULL;
l_description           := NULL;


 
 IF 
l_ledger_language = 'US' THEN
    l_description :=  SUBSTR(CONCAT(l_description,' Check Number:'),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000); 
 END IF;   
  l_source := SUBSTR(TO_CHAR(p_source_1),1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000);
  END IF;  
 IF 
l_ledger_language = 'US' THEN
    l_description :=  SUBSTR(CONCAT(l_description,'     Check Date:'),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000); 
 END IF;   
  l_source := SUBSTR(xla_ae_sources_pkg.DATE_TO_CHAR(p_source_2,
                     xla_ae_journal_entry_pkg.g_cache_ledgers_info.nls_desc_language),1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000);
  END IF;  
 IF 
l_ledger_language = 'US' THEN
    l_description :=  SUBSTR(CONCAT(l_description,'     Treasury Pay Number:'),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000); 
 END IF;   
  l_source := SUBSTR(TO_CHAR(p_source_3),1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,' '),1,2000);
  END IF; 
 l_description := SUBSTR(l_description,1,1996);
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of Description_1'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

  END IF;
  RETURN l_description;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Description_1'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN NULL;
EXCEPTION
  WHEN VALUE_ERROR THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
     END IF;
     RAISE;
 WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: '||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      END IF;
      RAISE;
 WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.Description_1');
END Description_1;

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_2
--
---------------------------------------
FUNCTION AcctDerRule_2 (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 
--FV_AP_CASH_ACCOUNT
 , p_source_4            IN NUMBER
--When to Account for Payment Option
 , p_source_5            IN VARCHAR2
--FV_AP_CASH_CLEARING_CCID
 , p_source_6            IN NUMBER
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_flexfield_segment_code     OUT NOCOPY VARCHAR2
, x_flex_value_set_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
, x_value_combination_id       OUT NOCOPY NUMBER
, x_value_segment_code         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         VARCHAR2(30)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_2';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctDerRule_2'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_INV_PMT_ACCOUNT_SEG';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
x_flexfield_segment_code := 'GL_ACCOUNT';
x_flex_value_set_id      :=  null ;


 IF NVL(p_source_5,'
') =  'ISSUE_ISSUE'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_2'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := TO_NUMBER(p_source_4) ;
  x_value_segment_code    := 'GL_ACCOUNT' ;
  x_value_type_code       := 'S';
  l_output_value          :=  null;
  RETURN l_output_value;

 ELSIF NVL(p_source_5,'
') <>  'ISSUE_ISSUE'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_2'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := TO_NUMBER(p_source_6) ;
  x_value_segment_code    := 'GL_ACCOUNT' ;
  x_value_type_code       := 'S';
  l_output_value          :=  null;
  RETURN l_output_value;

 ELSE 
    IF p_override_seg_flag = 'Y' THEN 
       RETURN '#$NO_OVERRIDE#$';
    END IF;
 END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_2(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_2');
END AcctDerRule_2;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_3
--
---------------------------------------
FUNCTION AcctDerRule_3 (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 
--DIT_CONFIRM_CASH_ACCOUNT
 , p_source_7            IN VARCHAR2
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_flexfield_segment_code     OUT NOCOPY VARCHAR2
, x_flex_value_set_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
, x_value_combination_id       OUT NOCOPY NUMBER
, x_value_segment_code         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         VARCHAR2(30)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_3';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctDerRule_3'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_TREASURY_CONFIRM_CASH_ACCT';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
x_flexfield_segment_code := 'GL_ACCOUNT';
x_flex_value_set_id      :=  null ;


--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_3'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  :=  null ;
  x_value_segment_code    :=  null ;
  x_value_type_code       := 'S';
  l_output_value          := TO_CHAR(p_source_7);
  RETURN l_output_value;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_3(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_3');
END AcctDerRule_3;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_4
--
---------------------------------------
FUNCTION AcctDerRule_4 (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--Automatic Offsets Value
 , p_source_9            IN VARCHAR2
 , p_source_9_meaning    IN VARCHAR2
--FV_AP_LIABILITY_ACCOUNT
 , p_source_10            IN NUMBER
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_flexfield_segment_code     OUT NOCOPY VARCHAR2
, x_flex_value_set_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
, x_value_combination_id       OUT NOCOPY NUMBER
, x_value_segment_code         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         VARCHAR2(30)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_4';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctDerRule_4'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_INV_PMT_BAL_SEG';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
x_flexfield_segment_code := 'GL_BALANCING';
x_flex_value_set_id      :=  null ;


 IF NVL(p_source_9,'
') =  'ACCOUNT_SEGMENT_VALUE' OR 
NVL(p_source_9,'
') =  'BALANCING_SEGMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_4'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := TO_NUMBER(p_source_8) ;
  x_value_segment_code    := 'GL_BALANCING' ;
  x_value_type_code       := 'S';
  l_output_value          :=  null;
  RETURN l_output_value;

 ELSIF NVL(p_source_9,'
') <>  'ACCOUNT_SEGMENT_VALUE' OR 
NVL(p_source_9,'
') <>  'BALANCING_SEGMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_4'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := TO_NUMBER(p_source_10) ;
  x_value_segment_code    := 'GL_BALANCING' ;
  x_value_type_code       := 'S';
  l_output_value          :=  null;
  RETURN l_output_value;

 ELSE 
    IF p_override_seg_flag = 'Y' THEN 
       RETURN '#$NO_OVERRIDE#$';
    END IF;
 END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_4(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_4');
END AcctDerRule_4;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_5
--
---------------------------------------
FUNCTION AcctDerRule_5 (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 
--FV_INV_TYPE_LOOKUP_CODE
 , p_source_11            IN VARCHAR2
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_flexfield_segment_code     OUT NOCOPY VARCHAR2
, x_flex_value_set_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
, x_value_combination_id       OUT NOCOPY NUMBER
, x_value_segment_code         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         VARCHAR2(30)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_5';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctDerRule_5'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_4X0101_TREASURY_PAY_ACCT';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
x_flexfield_segment_code :=  null;
x_flex_value_set_id      := 1009961 ;


 IF NVL(p_source_11,'
') <>  'PREPAYMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_5'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  :=  null ;
  x_value_segment_code    :=  null ;
  x_value_type_code       := 'C';
  l_output_value          := '490101';
  RETURN l_output_value;

 ELSIF NVL(p_source_11,'
') =  'PREPAYMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_5'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  :=  null ;
  x_value_segment_code    :=  null ;
  x_value_type_code       := 'C';
  l_output_value          := '480101';
  RETURN l_output_value;

 ELSE 
    IF p_override_seg_flag = 'Y' THEN 
       RETURN '#$NO_OVERRIDE#$';
    END IF;
 END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_5(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_5');
END AcctDerRule_5;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_6
--
---------------------------------------
FUNCTION AcctDerRule_6 (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 
--FV_INV_TYPE_LOOKUP_CODE
 , p_source_11            IN VARCHAR2
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_flexfield_segment_code     OUT NOCOPY VARCHAR2
, x_flex_value_set_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
, x_value_combination_id       OUT NOCOPY NUMBER
, x_value_segment_code         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         VARCHAR2(30)  ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_6';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctDerRule_6'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_4X0201_TREASURY_PAY_ACCT';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
x_flexfield_segment_code :=  null;
x_flex_value_set_id      := 1009961 ;


 IF NVL(p_source_11,'
') <>  'PREPAYMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_6'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  :=  null ;
  x_value_segment_code    :=  null ;
  x_value_type_code       := 'C';
  l_output_value          := '490201';
  RETURN l_output_value;

 ELSIF NVL(p_source_11,'
') =  'PREPAYMENT'
 THEN 
--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_6'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  :=  null ;
  x_value_segment_code    :=  null ;
  x_value_type_code       := 'C';
  l_output_value          := '480201';
  RETURN l_output_value;

 ELSE 
    IF p_override_seg_flag = 'Y' THEN 
       RETURN '#$NO_OVERRIDE#$';
    END IF;
 END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AcctDerRule_6(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_6');
END AcctDerRule_6;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_7
--
---------------------------------------
FUNCTION AcctDerRule_7 (
  p_application_id              IN NUMBER
, p_ae_header_id                IN NUMBER
, p_side                        IN VARCHAR2 
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
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
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_7';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of AcctDerRule_7'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_INV_DIST_ACCOUNT';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
--

 --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_7'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := 'S';
  l_output_value    := TO_NUMBER(TO_NUMBER(p_source_8));
  RETURN l_output_value;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_7(invalid)'
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_7');
END AcctDerRule_7;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_8
--
---------------------------------------
FUNCTION AcctDerRule_8 (
  p_application_id              IN NUMBER
, p_ae_header_id                IN NUMBER
, p_side                        IN VARCHAR2 
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--Automatic Offsets Value
 , p_source_9            IN VARCHAR2
 , p_source_9_meaning    IN VARCHAR2
--FV_AP_LIABILITY_ACCOUNT
 , p_source_10            IN NUMBER
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
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_8';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of AcctDerRule_8'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_component_type         := 'AMB_ADR';
l_component_code         := 'FV_INV_PMT_ACCOUNT';
l_component_type_code    := 'S';
l_component_appl_id      :=  8901;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
--

 IF NVL(p_source_9,'
') =  'ACCOUNT_SEGMENT_VALUE'
 THEN 
 --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_8'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := 'S';
  l_output_value    := TO_NUMBER(TO_NUMBER(p_source_8));
  RETURN l_output_value;

 ELSIF NVL(p_source_9,'
') <>  'ACCOUNT_SEGMENT_VALUE'
 THEN 
 --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_8'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := 'S';
  l_output_value    := TO_NUMBER(TO_NUMBER(p_source_10));
  RETURN l_output_value;

 END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_8(invalid)'
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctDerRule_8');
END AcctDerRule_8;
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
 
--FV_CHECK_NUMBER
 , p_source_1            IN NUMBER
--FV_CHECK_DATE
 , p_source_2            IN DATE
--FV_TREASURY_PAY_NUMBER
 , p_source_3            IN NUMBER
--FV_AP_CASH_ACCOUNT
 , p_source_4            IN NUMBER
--When to Account for Payment Option
 , p_source_5            IN VARCHAR2
--FV_AP_CASH_CLEARING_CCID
 , p_source_6            IN NUMBER
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--Automatic Offsets Value
 , p_source_9            IN VARCHAR2
 , p_source_9_meaning    IN VARCHAR2
--FV_AP_LIABILITY_ACCOUNT
 , p_source_10            IN NUMBER
--TREASURY_CONFIRMATION_ID
 , p_source_13            IN NUMBER
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_INV_EXCHANGE_DATE
 , p_source_21            IN DATE
--FV_INV_EXCHANGE_RATE
 , p_source_22            IN NUMBER
--FV_INV_EXCHANGE_RATE_TYPE
 , p_source_23            IN VARCHAR2
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
l_component_code             := 'FV_TC_CASH_ACCT_DR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAYMENT_DR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_CONFIRM' AND 
p_source_13 IS NOT NULL 
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 13;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(10)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(11)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(12)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(13) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_19;

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
   
xla_ae_lines_pkg.SetLineDescription(
   p_ae_header_id => l_ae_header_id
  ,p_description  => Description_1 (
     p_application_id         => p_application_id
   , p_ae_header_id           => l_ae_header_id 
, p_source_1 => p_source_1
, p_source_2 => p_source_2
, p_source_3 => p_source_3
   )
);


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
   
  l_ccid := AcctDerRule_8(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
, p_source_9 => p_source_9
, p_source_9_meaning => p_source_9_meaning
, p_source_10 => p_source_10
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
  , p_adr_code                     => 'FV_INV_PMT_ACCOUNT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   l_segment := AcctDerRule_2(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_4 => p_source_4
, p_source_5 => p_source_5
, p_source_6 => p_source_6
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_ACCOUNT'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_INV_PMT_ACCOUNT_SEG'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

   l_segment := AcctDerRule_4(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
, p_source_9 => p_source_9
, p_source_9_meaning => p_source_9_meaning
, p_source_10 => p_source_10
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_BALANCING'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_INV_PMT_BAL_SEG'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_9');
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
 
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_REV_PAY_HIST_DIST_ID
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
l_component_code             := 'FV_TC_CASH_ACCT_REV_CR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAYMENT_DR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_BACKOUT' OR 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_VOID'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 10;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_24);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(10)  := p_source_19;

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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_10');
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
 
--FV_CHECK_NUMBER
 , p_source_1            IN NUMBER
--FV_CHECK_DATE
 , p_source_2            IN DATE
--FV_TREASURY_PAY_NUMBER
 , p_source_3            IN NUMBER
--DIT_CONFIRM_CASH_ACCOUNT
 , p_source_7            IN VARCHAR2
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--Automatic Offsets Value
 , p_source_9            IN VARCHAR2
 , p_source_9_meaning    IN VARCHAR2
--FV_AP_LIABILITY_ACCOUNT
 , p_source_10            IN NUMBER
--TREASURY_CONFIRMATION_ID
 , p_source_13            IN NUMBER
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_INV_EXCHANGE_DATE
 , p_source_21            IN DATE
--FV_INV_EXCHANGE_RATE
 , p_source_22            IN NUMBER
--FV_INV_EXCHANGE_RATE_TYPE
 , p_source_23            IN VARCHAR2
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
l_component_code             := 'FV_TC_DISB_TRANSIT_CR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAYMENT_CR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_CONFIRM' AND 
p_source_13 IS NOT NULL 
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 13;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(10)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(11)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(12)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(13) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_19;

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
   
xla_ae_lines_pkg.SetLineDescription(
   p_ae_header_id => l_ae_header_id
  ,p_description  => Description_1 (
     p_application_id         => p_application_id
   , p_ae_header_id           => l_ae_header_id 
, p_source_1 => p_source_1
, p_source_2 => p_source_2
, p_source_3 => p_source_3
   )
);


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
   
  l_ccid := AcctDerRule_8(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
, p_source_9 => p_source_9
, p_source_9_meaning => p_source_9_meaning
, p_source_10 => p_source_10
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
  , p_adr_code                     => 'FV_INV_PMT_ACCOUNT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   l_segment := AcctDerRule_4(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
, p_source_9 => p_source_9
, p_source_9_meaning => p_source_9_meaning
, p_source_10 => p_source_10
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_BALANCING'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_INV_PMT_BAL_SEG'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

   l_segment := AcctDerRule_3(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_7 => p_source_7
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_ACCOUNT'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_TREASURY_CONFIRM_CASH_ACCT'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_11');
END AcctLineType_11;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_12
--
---------------------------------------
PROCEDURE AcctLineType_12 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_REV_PAY_HIST_DIST_ID
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
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_12';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_12'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'FV_TC_DISB_TRANSIT_REV_DR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAYMENT_CR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_BACKOUT' OR 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_VOID'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 10;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_24);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(10)  := p_source_19;

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
      (p_msg      => 'END of AcctLineType_12'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_12');
END AcctLineType_12;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_13
--
---------------------------------------
PROCEDURE AcctLineType_13 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--FV_CHECK_NUMBER
 , p_source_1            IN NUMBER
--FV_CHECK_DATE
 , p_source_2            IN DATE
--FV_TREASURY_PAY_NUMBER
 , p_source_3            IN NUMBER
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--FV_INV_TYPE_LOOKUP_CODE
 , p_source_11            IN VARCHAR2
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_INV_EXCHANGE_DATE
 , p_source_21            IN DATE
--FV_INV_EXCHANGE_RATE
 , p_source_22            IN NUMBER
--FV_INV_EXCHANGE_RATE_TYPE
 , p_source_23            IN VARCHAR2
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
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_13';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_13'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'FV_TC_PAID_ACCT_CR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAID_CR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_CONFIRM'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 13;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(10)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(11)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(12)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(13) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_19;

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
   
xla_ae_lines_pkg.SetLineDescription(
   p_ae_header_id => l_ae_header_id
  ,p_description  => Description_1 (
     p_application_id         => p_application_id
   , p_ae_header_id           => l_ae_header_id 
, p_source_1 => p_source_1
, p_source_2 => p_source_2
, p_source_3 => p_source_3
   )
);


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
   
  l_ccid := AcctDerRule_7(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
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
  , p_adr_code                     => 'FV_INV_DIST_ACCOUNT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   l_segment := AcctDerRule_6(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_11 => p_source_11
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_ACCOUNT'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_4X0201_TREASURY_PAY_ACCT'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

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
      (p_msg      => 'END of AcctLineType_13'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_13');
END AcctLineType_13;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_14
--
---------------------------------------
PROCEDURE AcctLineType_14 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_REV_PAY_HIST_DIST_ID
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
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_14';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_14'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'FV_TC_PAID_ACCT_REV_DR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAID_CR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_BACKOUT' OR 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_VOID'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 10;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_24);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(10)  := p_source_19;

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
      (p_msg      => 'END of AcctLineType_14'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_14');
END AcctLineType_14;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_15
--
---------------------------------------
PROCEDURE AcctLineType_15 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--FV_CHECK_NUMBER
 , p_source_1            IN NUMBER
--FV_CHECK_DATE
 , p_source_2            IN DATE
--FV_TREASURY_PAY_NUMBER
 , p_source_3            IN NUMBER
--FV_INV_DIST_CCID
 , p_source_8            IN NUMBER
--FV_INV_TYPE_LOOKUP_CODE
 , p_source_11            IN VARCHAR2
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_INV_EXCHANGE_DATE
 , p_source_21            IN DATE
--FV_INV_EXCHANGE_RATE
 , p_source_22            IN NUMBER
--FV_INV_EXCHANGE_RATE_TYPE
 , p_source_23            IN VARCHAR2
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
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_15';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_15'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'FV_TC_UNPAID_ACCT_DR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAID_DR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_CONFIRM'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 13;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(10)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(11)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(12)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(13) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_19;

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
   
xla_ae_lines_pkg.SetLineDescription(
   p_ae_header_id => l_ae_header_id
  ,p_description  => Description_1 (
     p_application_id         => p_application_id
   , p_ae_header_id           => l_ae_header_id 
, p_source_1 => p_source_1
, p_source_2 => p_source_2
, p_source_3 => p_source_3
   )
);


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
   
  l_ccid := AcctDerRule_7(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_8 => p_source_8
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
  , p_adr_code                     => 'FV_INV_DIST_ACCOUNT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   l_segment := AcctDerRule_5(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_11 => p_source_11
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => 'NA'
         , p_override_seg_flag        => 'Y'
   );

   IF NVL(l_segment,'NULL') <> '#$NO_OVERRIDE#$' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => 'GL_ACCOUNT'
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => 'FV_4X0101_TREASURY_PAY_ACCT'
        , p_adr_type_code           => 'S'
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => 'TREASURY_CONFIRMATION'
        , p_event_class_code        => 'TREASURY_ACCOMPLISHMENT'
        , p_side                    => 'NA'
        );

  END IF;

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
      (p_msg      => 'END of AcctLineType_15'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_15');
END AcctLineType_15;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_16
--
---------------------------------------
PROCEDURE AcctLineType_16 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--FV_BUS_FLOW_FV_APP_ID
 , p_source_14            IN NUMBER
--FV_BUS_FLOW_TREASURY_DIST_TYPE
 , p_source_15            IN VARCHAR2
--FV_BUS_FLOW_TREAS_ENTITY_CODE
 , p_source_16            IN VARCHAR2
--FV_PAY_HIST_DIST_ID
 , p_source_17            IN NUMBER
--FV_TREASURY_CONFIRMATION_ID
 , p_source_18            IN NUMBER
--FV_PAY_DIST_AMOUNT
 , p_source_19            IN NUMBER
--FV_INV_CURRENCY_CODE
 , p_source_20            IN VARCHAR2
--FV_REV_PAY_HIST_DIST_ID
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
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_16';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_16'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'FV_TC_UNPAID_ACCT_REV_CR';
l_component_type_code        := 'S';
l_component_appl_id          :=  8901;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'TREASURY_CONFIRMATION';
l_event_class_code           := 'TREASURY_ACCOMPLISHMENT';
l_event_type_code            := 'TREASURY_ACCOMPLISHMENT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'FV_TREASURY_PAYMENTS_ALL';
--
l_balance_type_code          := 'A';
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
l_bflow_class_code           := 'FV_TC_PAID_DR';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'N';

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
IF NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_BACKOUT' OR 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'TREASURY_VOID'
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
         , p_acct_entry_type_code       => 'A'
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
           p_accounting_class_code  => 'ACCOUNTSPAYABLE'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'ACCOUNTSPAYABLE';

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
   l_entered_amt_idx := 8;
   l_accted_amt_idx  := 10;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_14;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_24);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_18);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_17);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(9)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(10)  := p_source_19;

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
      (p_msg      => 'END of AcctLineType_16'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_08901_AAD_S_000003_PKG.AcctLineType_16');
END AcctLineType_16;
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

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'BUDGET_EXECUTION_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'BUDGET_EXECUTION';
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
               WHEN 1 THEN 'FV_BE_BA_FD_HDR_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '8901' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'GL_DATE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h1.GL_DATE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM xla_events_gt     xet  
      , FV_BE_BA_FD_HDR_V  h1
             ,(select rownum r from all_objects where rownum <= 1 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id

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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.insert_sources_17');
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
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'BUDGET_EXECUTION_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'BUDGET_EXECUTION';

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
l_event_class_name          VARCHAR2(80) := 'Budget Execution Transactions';
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

TYPE t_array_source_25 IS TABLE OF FV_BE_BA_FD_HDR_V.GL_DATE%TYPE INDEX BY BINARY_INTEGER;


l_array_source_25              t_array_source_25;


--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: BUDGET_EXECUTION
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
  , h1.GL_DATE    source_25
  FROM xla_events_gt     xet 
  , FV_BE_BA_FD_HDR_V  h1
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id

 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: BUDGET_EXECUTION
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
 , 0 
  FROM xla_events_gt     xet  
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  ;

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
      , l_array_source_25
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

g_array_event(l_event_id).array_value_date('source_25') := l_array_source_25(hdr_idx);

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
      l_rec_acct_attrs.array_date_value(1) := g_array_event(l_event_id).array_value_date('source_25');


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
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_08901_AAD_S_000003_PKG.EventClass_17');
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

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'RPR_BUDGET_EXECUTION_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'RPR_BUDGET_EXECUTION';
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
               WHEN 1 THEN 'FV_BE_RPR_HDR_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '8901' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'GL_DATE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h1.GL_DATE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM xla_events_gt     xet  
      , FV_BE_RPR_HDR_V  h1
             ,(select rownum r from all_objects where rownum <= 1 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id

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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.insert_sources_18');
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
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'RPR_BUDGET_EXECUTION_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'RPR_BUDGET_EXECUTION';

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
l_event_class_name          VARCHAR2(80) := 'Reprogram Budget Execution Transactions';
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

TYPE t_array_source_25 IS TABLE OF FV_BE_RPR_HDR_V.GL_DATE%TYPE INDEX BY BINARY_INTEGER;


l_array_source_25              t_array_source_25;


--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: RPR_BUDGET_EXECUTION
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
  , h1.GL_DATE    source_25
  FROM xla_events_gt     xet 
  , FV_BE_RPR_HDR_V  h1
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id

 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: RPR_BUDGET_EXECUTION
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
 , 0 
  FROM xla_events_gt     xet  
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  ;

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
      , l_array_source_25
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

g_array_event(l_event_id).array_value_date('source_25') := l_array_source_25(hdr_idx);

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
      l_rec_acct_attrs.array_date_value(1) := g_array_event(l_event_id).array_value_date('source_25');


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
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_08901_AAD_S_000003_PKG.EventClass_18');
END EventClass_18;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_19
--
----------------------------------------
--
PROCEDURE insert_sources_19(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'TREASURY_ACCOMPLISHMENT_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'TREASURY_ACCOMPLISHMENT';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_19';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_19'
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
               WHEN 1 THEN 'AP_SYSTEM_PARAMETERS_EXTRACT_V' 
                WHEN 2 THEN 'AP_SYSTEM_PARAMETERS_EXTRACT_V' 
                WHEN 3 THEN 'FV_TREASURY_EXTRACT_HEADER_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '200' 
                WHEN 2 THEN '200' 
                WHEN 3 THEN '8901' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'ASP_WHEN_TO_ACCOUNT_PMT' 
                WHEN 2 THEN 'ASP_AUTOMATIC_OFFSETS_VALUE' 
                WHEN 3 THEN 'TREASURY_CONFIRMATION_ID' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h1.ASP_WHEN_TO_ACCOUNT_PMT)
                WHEN 2 THEN TO_CHAR(h1.ASP_AUTOMATIC_OFFSETS_VALUE)
                WHEN 3 THEN TO_CHAR(h3.TREASURY_CONFIRMATION_ID)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 2 THEN fvl9.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , AP_SYSTEM_PARAMETERS_EXTRACT_V  h1
      , FV_TREASURY_EXTRACT_HEADER_V  h3
  , fnd_lookup_values    fvl9
             ,(select rownum r from all_objects where rownum <= 3 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h3.event_id = xet.event_id
 AND h3.org_id = h1.asp_org_id   AND fvl9.lookup_type(+)         = 'LIABILITY FLEXBUILD METHOD'
  AND fvl9.lookup_code(+)         = h1.ASP_AUTOMATIC_OFFSETS_VALUE
  AND fvl9.view_application_id(+) = 200
  AND fvl9.language(+)            = USERENV('LANG')
  
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
               WHEN 1 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 2 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 3 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 4 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 5 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 6 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 7 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 8 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 9 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 10 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 11 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 12 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 13 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 14 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 15 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 16 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 17 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 18 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 19 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                WHEN 20 THEN 'FV_TREASURY_EXTRACT_DETAILS_V' 
                
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
                WHEN 10 THEN 'LINE' 
                WHEN 11 THEN 'LINE' 
                WHEN 12 THEN 'LINE' 
                WHEN 13 THEN 'LINE' 
                WHEN 14 THEN 'LINE' 
                WHEN 15 THEN 'LINE' 
                WHEN 16 THEN 'LINE' 
                WHEN 17 THEN 'LINE' 
                WHEN 18 THEN 'LINE' 
                WHEN 19 THEN 'LINE' 
                WHEN 20 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '8901' 
                WHEN 2 THEN '8901' 
                WHEN 3 THEN '8901' 
                WHEN 4 THEN '8901' 
                WHEN 5 THEN '8901' 
                WHEN 6 THEN '8901' 
                WHEN 7 THEN '8901' 
                WHEN 8 THEN '8901' 
                WHEN 9 THEN '8901' 
                WHEN 10 THEN '8901' 
                WHEN 11 THEN '8901' 
                WHEN 12 THEN '8901' 
                WHEN 13 THEN '8901' 
                WHEN 14 THEN '8901' 
                WHEN 15 THEN '8901' 
                WHEN 16 THEN '8901' 
                WHEN 17 THEN '8901' 
                WHEN 18 THEN '8901' 
                WHEN 19 THEN '8901' 
                WHEN 20 THEN '8901' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'FV_CHECK_NUMBER' 
                WHEN 2 THEN 'FV_CHECK_DATE' 
                WHEN 3 THEN 'FV_TREASURY_PAY_NUMBER' 
                WHEN 4 THEN 'FV_AP_CASH_ACCOUNT' 
                WHEN 5 THEN 'FV_AP_CASH_CLEARING_CCID' 
                WHEN 6 THEN 'DIT_CONFIRM_CASH_ACCOUNT' 
                WHEN 7 THEN 'FV_INV_DIST_CCID' 
                WHEN 8 THEN 'FV_AP_LIABILITY_ACCOUNT' 
                WHEN 9 THEN 'FV_INV_TYPE_LOOKUP_CODE' 
                WHEN 10 THEN 'FV_BUS_FLOW_FV_APP_ID' 
                WHEN 11 THEN 'FV_BUS_FLOW_TREASURY_DIST_TYPE' 
                WHEN 12 THEN 'FV_BUS_FLOW_TREAS_ENTITY_CODE' 
                WHEN 13 THEN 'FV_PAY_HIST_DIST_ID' 
                WHEN 14 THEN 'FV_TREASURY_CONFIRMATION_ID' 
                WHEN 15 THEN 'FV_PAY_DIST_AMOUNT' 
                WHEN 16 THEN 'FV_INV_CURRENCY_CODE' 
                WHEN 17 THEN 'FV_INV_EXCHANGE_DATE' 
                WHEN 18 THEN 'FV_INV_EXCHANGE_RATE' 
                WHEN 19 THEN 'FV_INV_EXCHANGE_RATE_TYPE' 
                WHEN 20 THEN 'FV_REV_PAY_HIST_DIST_ID' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.FV_CHECK_NUMBER)
                WHEN 2 THEN TO_CHAR(l2.FV_CHECK_DATE)
                WHEN 3 THEN TO_CHAR(l2.FV_TREASURY_PAY_NUMBER)
                WHEN 4 THEN TO_CHAR(l2.FV_AP_CASH_ACCOUNT)
                WHEN 5 THEN TO_CHAR(l2.FV_AP_CASH_CLEARING_CCID)
                WHEN 6 THEN TO_CHAR(l2.DIT_CONFIRM_CASH_ACCOUNT)
                WHEN 7 THEN TO_CHAR(l2.FV_INV_DIST_CCID)
                WHEN 8 THEN TO_CHAR(l2.FV_AP_LIABILITY_ACCOUNT)
                WHEN 9 THEN TO_CHAR(l2.FV_INV_TYPE_LOOKUP_CODE)
                WHEN 10 THEN TO_CHAR(l2.FV_BUS_FLOW_FV_APP_ID)
                WHEN 11 THEN TO_CHAR(l2.FV_BUS_FLOW_TREASURY_DIST_TYPE)
                WHEN 12 THEN TO_CHAR(l2.FV_BUS_FLOW_TREAS_ENTITY_CODE)
                WHEN 13 THEN TO_CHAR(l2.FV_PAY_HIST_DIST_ID)
                WHEN 14 THEN TO_CHAR(l2.FV_TREASURY_CONFIRMATION_ID)
                WHEN 15 THEN TO_CHAR(l2.FV_PAY_DIST_AMOUNT)
                WHEN 16 THEN TO_CHAR(l2.FV_INV_CURRENCY_CODE)
                WHEN 17 THEN TO_CHAR(l2.FV_INV_EXCHANGE_DATE)
                WHEN 18 THEN TO_CHAR(l2.FV_INV_EXCHANGE_RATE)
                WHEN 19 THEN TO_CHAR(l2.FV_INV_EXCHANGE_RATE_TYPE)
                WHEN 20 THEN TO_CHAR(l2.FV_REV_PAY_HIST_DIST_ID)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , FV_TREASURY_EXTRACT_DETAILS_V  l2
            , (select rownum r from all_objects where rownum <= 20 and owner = p_apps_owner)
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
         (p_msg      => 'END of insert_sources_19'
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
           (p_location => 'XLA_08901_AAD_S_000003_PKG.insert_sources_19');
END insert_sources_19;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_19
--
----------------------------------------
--
FUNCTION EventClass_19
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
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'TREASURY_ACCOMPLISHMENT_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'TREASURY_ACCOMPLISHMENT';

l_calculate_acctd_flag   VARCHAR2(1) :='Y';
l_calculate_g_l_flag     VARCHAR2(1) :='Y';
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
l_event_class_name          VARCHAR2(80) := 'Treasury Accomplishment';
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

TYPE t_array_source_5 IS TABLE OF AP_SYSTEM_PARAMETERS_EXTRACT_V.ASP_WHEN_TO_ACCOUNT_PMT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_9 IS TABLE OF AP_SYSTEM_PARAMETERS_EXTRACT_V.ASP_AUTOMATIC_OFFSETS_VALUE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF FV_TREASURY_EXTRACT_HEADER_V.TREASURY_CONFIRMATION_ID%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_1 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_CHECK_NUMBER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_2 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_CHECK_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_3 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_TREASURY_PAY_NUMBER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_4 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_AP_CASH_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_6 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_AP_CASH_CLEARING_CCID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.DIT_CONFIRM_CASH_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_8 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_DIST_CCID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_10 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_AP_LIABILITY_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_11 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_TYPE_LOOKUP_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_14 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_BUS_FLOW_FV_APP_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_BUS_FLOW_TREASURY_DIST_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_BUS_FLOW_TREAS_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_PAY_HIST_DIST_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_18 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_TREASURY_CONFIRMATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_19 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_PAY_DIST_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_20 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_21 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_EXCHANGE_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_22 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_23 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_INV_EXCHANGE_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_24 IS TABLE OF FV_TREASURY_EXTRACT_DETAILS_V.FV_REV_PAY_HIST_DIST_ID%TYPE INDEX BY BINARY_INTEGER;

l_array_source_5              t_array_source_5;
l_array_source_9              t_array_source_9;
l_array_source_9_meaning      t_array_lookup_meaning;
l_array_source_13              t_array_source_13;

l_array_source_1      t_array_source_1;
l_array_source_2      t_array_source_2;
l_array_source_3      t_array_source_3;
l_array_source_4      t_array_source_4;
l_array_source_6      t_array_source_6;
l_array_source_7      t_array_source_7;
l_array_source_8      t_array_source_8;
l_array_source_10      t_array_source_10;
l_array_source_11      t_array_source_11;
l_array_source_14      t_array_source_14;
l_array_source_15      t_array_source_15;
l_array_source_16      t_array_source_16;
l_array_source_17      t_array_source_17;
l_array_source_18      t_array_source_18;
l_array_source_19      t_array_source_19;
l_array_source_20      t_array_source_20;
l_array_source_21      t_array_source_21;
l_array_source_22      t_array_source_22;
l_array_source_23      t_array_source_23;
l_array_source_24      t_array_source_24;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: TREASURY_ACCOMPLISHMENT
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
  , h1.ASP_WHEN_TO_ACCOUNT_PMT    source_5
  , h1.ASP_AUTOMATIC_OFFSETS_VALUE    source_9
  , fvl9.meaning   source_9_meaning
  , h3.TREASURY_CONFIRMATION_ID    source_13
  FROM xla_events_gt     xet 
  , AP_SYSTEM_PARAMETERS_EXTRACT_V  h1
  , FV_TREASURY_EXTRACT_HEADER_V  h3
  , fnd_lookup_values    fvl9
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h3.event_id = xet.event_id
 AND h3.org_id = h1.asp_org_id   AND fvl9.lookup_type(+)         = 'LIABILITY FLEXBUILD METHOD'
  AND fvl9.lookup_code(+)         = h1.ASP_AUTOMATIC_OFFSETS_VALUE
  AND fvl9.view_application_id(+) = 200
  AND fvl9.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: TREASURY_ACCOMPLISHMENT
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
  , l2.FV_CHECK_NUMBER    source_1
  , l2.FV_CHECK_DATE    source_2
  , l2.FV_TREASURY_PAY_NUMBER    source_3
  , l2.FV_AP_CASH_ACCOUNT    source_4
  , l2.FV_AP_CASH_CLEARING_CCID    source_6
  , l2.DIT_CONFIRM_CASH_ACCOUNT    source_7
  , l2.FV_INV_DIST_CCID    source_8
  , l2.FV_AP_LIABILITY_ACCOUNT    source_10
  , l2.FV_INV_TYPE_LOOKUP_CODE    source_11
  , l2.FV_BUS_FLOW_FV_APP_ID    source_14
  , l2.FV_BUS_FLOW_TREASURY_DIST_TYPE    source_15
  , l2.FV_BUS_FLOW_TREAS_ENTITY_CODE    source_16
  , l2.FV_PAY_HIST_DIST_ID    source_17
  , l2.FV_TREASURY_CONFIRMATION_ID    source_18
  , l2.FV_PAY_DIST_AMOUNT    source_19
  , l2.FV_INV_CURRENCY_CODE    source_20
  , l2.FV_INV_EXCHANGE_DATE    source_21
  , l2.FV_INV_EXCHANGE_RATE    source_22
  , l2.FV_INV_EXCHANGE_RATE_TYPE    source_23
  , l2.FV_REV_PAY_HIST_DIST_ID    source_24
  FROM xla_events_gt     xet 
  , FV_TREASURY_EXTRACT_DETAILS_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_19';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_19'
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
      , l_array_source_5
      , l_array_source_9
      , l_array_source_9_meaning
      , l_array_source_13
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

g_array_event(l_event_id).array_value_char('source_5') := l_array_source_5(hdr_idx);
g_array_event(l_event_id).array_value_char('source_9') := l_array_source_9(hdr_idx);
g_array_event(l_event_id).array_value_char('source_9_meaning') := l_array_source_9_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_13') := l_array_source_13(hdr_idx);

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
   p_source_code           => 'XLA_EVENT_DATE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);


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
      , l_array_source_2
      , l_array_source_3
      , l_array_source_4
      , l_array_source_6
      , l_array_source_7
      , l_array_source_8
      , l_array_source_10
      , l_array_source_11
      , l_array_source_14
      , l_array_source_15
      , l_array_source_16
      , l_array_source_17
      , l_array_source_18
      , l_array_source_19
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
AcctLineType_9 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_1 => l_array_source_1(Idx)
 , p_source_2 => l_array_source_2(Idx)
 , p_source_3 => l_array_source_3(Idx)
 , p_source_4 => l_array_source_4(Idx)
 , p_source_5 => g_array_event(l_event_id).array_value_char('source_5')
 , p_source_6 => l_array_source_6(Idx)
 , p_source_8 => l_array_source_8(Idx)
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_9_meaning => g_array_event(l_event_id).array_value_char('source_9_meaning')
 , p_source_10 => l_array_source_10(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_num('source_13')
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_10 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_24 => l_array_source_24(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


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
 , p_source_2 => l_array_source_2(Idx)
 , p_source_3 => l_array_source_3(Idx)
 , p_source_7 => l_array_source_7(Idx)
 , p_source_8 => l_array_source_8(Idx)
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_9_meaning => g_array_event(l_event_id).array_value_char('source_9_meaning')
 , p_source_10 => l_array_source_10(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_num('source_13')
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_12 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_24 => l_array_source_24(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_13 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_1 => l_array_source_1(Idx)
 , p_source_2 => l_array_source_2(Idx)
 , p_source_3 => l_array_source_3(Idx)
 , p_source_8 => l_array_source_8(Idx)
 , p_source_11 => l_array_source_11(Idx)
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_14 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_24 => l_array_source_24(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_15 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_1 => l_array_source_1(Idx)
 , p_source_2 => l_array_source_2(Idx)
 , p_source_3 => l_array_source_3(Idx)
 , p_source_8 => l_array_source_8(Idx)
 , p_source_11 => l_array_source_11(Idx)
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_16 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_14 => l_array_source_14(Idx)
 , p_source_15 => l_array_source_15(Idx)
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => l_array_source_17(Idx)
 , p_source_18 => l_array_source_18(Idx)
 , p_source_19 => l_array_source_19(Idx)
 , p_source_20 => l_array_source_20(Idx)
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
      (p_msg      => 'END of EventClass_19'
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
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_08901_AAD_S_000003_PKG.EventClass_19');
END EventClass_19;
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

l_created := EventClass_19(
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

         insert_sources_19(
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
      (p_location => 'XLA_08901_AAD_S_000003_PKG.CreateHeadersAndLines');
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
   (p_product_rule_code      => 'FV_STANDARD_AAD'
   ,p_product_rule_type_code => 'S'
   ,p_product_rule_version   => ''
   ,p_product_rule_name      => 'Federal Financials AAD'
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
      (p_location => 'XLA_08901_AAD_S_000003_PKG.CreateJournalEntries');
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
END XLA_08901_AAD_S_000003_PKG;
--

/
