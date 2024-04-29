--------------------------------------------------------
--  DDL for Package Body XLA_CMP_ADR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_ADR_PKG" AS
/* $Header: xlacpadr.pkb 120.43.12010000.2 2010/01/31 14:48:43 vkasina ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_adr_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate ADR procedures from AMB specifcations                      |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     25-FEB-2003 K.Boussema    Revised GenerateADRProcs to filter account   |
|                               derivation rules to generate                 |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     17-APR-2003 K.Boussema    Included error messages                      |
|     26-MAI-2003 K.Boussema    Removed XLA_AP_INVALID_ADR error code        |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143  |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     30-JUL-2003 K.Boussema    Updated the definition of C_FLEXFIELD_SEGMENT|
|     13-NOV-2003 K.Boussema    Changed to pass to the accounting engine the |
|                               Accounting and transaction coa id values     |
|     20-NOV-2003 K.Boussema    Added the update of journal entry status     |
|                               bug 3269120                                  |
|     05-DEC-2003 K.Boussema    Added Accounting COA value in generation of  |
|                               SetCcid and SetOverride. Set Accounting COA  |
|                               to NULL if CCID source, bug3289875           |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     12-JAN-2004 K.Boussema    Changed GetSegment and GetCcid to fix issue  |
|                               described in bug 3366176                     |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     02-JUN-2004 A.Quaglia     Made changes for the Transaction Account     |
|                               Builder.                                     |
|                               Added generate_adr_spec                      |
|                               Added generate_tab_adr                       |
|                               Added build_adrs_for_tab                     |
|     23-JUL-2004 A.Quaglia   GetCcid: changed message tokens                |
|     23-Sep-2004 S.Singhania Minor change for Bulk processing.              |
|     27-SEP-2004 A.Quaglia   GetCcid: added selection of correct template   |
|                                      for constant ccid case, when compiling|
|                                      for the Transaction Account Builder   |
|     28-Feb-2005 W.Shen      Change for ledger currency project             |
|                                Add p_side parameter when call the generated|
|                                adr function, and the setccid/setsegment    |
|                                function in xla_ae_lines_pkg                |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A. Wan        4262811 for MPA project.                     |
|     26-Oct-2005 Jorge Larre The generation of the adr should consider the  |
|                             case of the TAB as similar as the case of      |
|                             flexfield mode:                                |
|    Old code:                                                               |
|    IF NOT l_endif and l_adr IS NOT NULL THEN                               |
|       IF p_flexfield_assign_mode = 'A' THEN                                |
|          l_adr := l_adr ||g_chr_newline||' END IF;';                       |
|    New code:                                                               |
|    IF NOT l_endif and l_adr IS NOT NULL THEN                               |
|       IF p_flexfield_assign_mode = 'A' OR g_component_type = 'TAB_ADR' THEN|
|          l_adr := l_adr ||g_chr_newline||' END IF;';                       |
+===========================================================================*/
--
--Global Exceptions
ge_fatal_error                 EXCEPTION;

--Global Constants
G_STANDARD_MESSAGE CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_STANDARD_MESSAGE;
G_OA_MESSAGE       CONSTANT VARCHAR2(1) := xla_exceptions_pkg.C_OA_MESSAGE;

g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;


/*------------------------------------------------------------+
|                                                             |
|                                                             |
|                         Global variables                    |
|                                                             |
|                                                             |
+-------------------------------------------------------------*/

g_component_type                VARCHAR2(30):='AMB_ADR';
g_component_code                VARCHAR2(30);
g_component_type_code           VARCHAR2(1);
g_component_appl_id             INTEGER;
g_component_name                VARCHAR2(160);
g_amb_context_code              VARCHAR2(30);
g_package_name                  VARCHAR2(30);

/*------------------------------------------------------------+
|                                                             |
|                                                             |
|             ADRs templates for AAD packages                 |
|                                                             |
|                                                             |
+-------------------------------------------------------------*/

C_ADR_SEGMENT                    CONSTANT      VARCHAR2(32000):= '
---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_$adr_hash_id$
--
---------------------------------------
FUNCTION AcctDerRule_$adr_hash_id$ (
  p_application_id             IN NUMBER
, p_ae_header_id               IN NUMBER
, p_side                       IN VARCHAR2
, p_override_seg_flag          IN VARCHAR2 $parameters$
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
      l_log_module := C_DEFAULT_MODULE||''.AcctDerRule_$adr_hash_id$'';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''BEGIN of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_component_type         := ''AMB_ADR'';
l_component_code         := ''$account_derivation_rule_code$'';
l_component_type_code    := ''$adr_type_code$'';
l_component_appl_id      :=  $adr_appl_id$;
l_amb_context_code       := ''$amb_context_code$'';
x_transaction_coa_id     := $transaction_coa_id$;
x_accounting_coa_id      := $accounting_coa_id$;
x_flexfield_segment_code := $flexfield_segment_code$;
x_flex_value_set_id      := $flex_value_set_id$ ;

$adr_body$

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$(invalid)''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_combination_id  := null;
x_value_segment_code    := null;
x_value_type_code       := null;
l_output_value          := null;
xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => ''XLA''
                 ,p_msg_name                => ''XLA_AP_INVALID_ADR''
                 ,p_token_1                 => ''COMPONENT_NAME''
                 ,p_value_1                 => xla_ae_sources_pkg.GetComponentName (
                                                            l_component_type
                                                          , l_component_code
                                                          , l_component_type_code
                                                          , l_component_appl_id
                                                          , l_amb_context_code
                                                          )
                 ,p_token_2                 => ''OWNER''
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                        ''XLA_OWNER_TYPE''
                                                        ,l_component_type_code
                                                        )
                 ,p_token_3                 => ''PAD_NAME''
                 ,p_value_3                 => xla_ae_journal_entry_pkg.g_cache_pad.pad_session_name
                 ,p_token_4                 => ''PAD_OWNER''
                 ,p_value_4                 => xla_lookups_pkg.get_meaning(
                                                        ''XLA_OWNER_TYPE''
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
           (p_location => ''$package_name$.AcctDerRule_$adr_hash_id$'');
END AcctDerRule_$adr_hash_id$;
--
';

--========================================================================

C_ADR_CCID                   CONSTANT      VARCHAR2(32000):= '
---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_$adr_hash_id$
--
---------------------------------------
FUNCTION AcctDerRule_$adr_hash_id$ (
  p_application_id              IN NUMBER
, p_ae_header_id                IN NUMBER
, p_side                        IN VARCHAR2 $parameters$
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
      l_log_module := C_DEFAULT_MODULE||''.AcctDerRule_$adr_hash_id$'';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''BEGIN of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_component_type         := ''AMB_ADR'';
l_component_code         := ''$account_derivation_rule_code$'';
l_component_type_code    := ''$adr_type_code$'';
l_component_appl_id      :=  $adr_appl_id$;
l_amb_context_code       := ''$amb_context_code$'';
x_transaction_coa_id     := $transaction_coa_id$;
x_accounting_coa_id      := $accounting_coa_id$;
--
$adr_body$
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$(invalid)''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_type_code := null;
l_output_value    := null;
xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => ''XLA''
                 ,p_msg_name                => ''XLA_AP_INVALID_ADR''
                 ,p_token_1                 => ''COMPONENT_NAME''
                 ,p_value_1                 => xla_ae_sources_pkg.GetComponentName (
                                                            l_component_type
                                                          , l_component_code
                                                          , l_component_type_code
                                                          , l_component_appl_id
                                                          , l_amb_context_code
                                                          )
                 ,p_token_2                 => ''OWNER''
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                        ''XLA_OWNER_TYPE''
                                                        ,l_component_type_code
                                                        )
                 ,p_token_3                 => ''PAD_NAME''
                 ,p_value_3                 => xla_ae_journal_entry_pkg.g_cache_pad.pad_session_name
                 ,p_token_4                 => ''PAD_OWNER''
                 ,p_value_4                 => xla_lookups_pkg.get_meaning(
                                                        ''XLA_OWNER_TYPE''
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
           (p_location => ''$package_name$.AcctDerRule_$adr_hash_id$'');
END AcctDerRule_$adr_hash_id$;
--
';

/*------------------------------------------------------------+
|                                                             |
|                                                             |
|                     Additions for TAB                       |
|                                                             |
|                                                             |
+-------------------------------------------------------------*/
--

C_ADR_CCID_TAD_FUNCT_NAME        CONSTANT      VARCHAR2(50):=
   'get_ccid_$adr_hash_id$';

C_ADR_CCID_TAD_FUNCT_SPEC        CONSTANT      VARCHAR2(10000):= '
---------------------------------------
--
-- PUBLIC FUNCTION
--         get_ccid_$adr_hash_id$
--
---------------------------------------
FUNCTION '|| C_ADR_CCID_TAD_FUNCT_NAME || ' (
 p_mode                            IN VARCHAR2
,p_rowid                           IN UROWID
,p_line_index                      IN NUMBER
,p_chart_of_accounts_id            IN NUMBER
,p_chart_of_accounts_name          IN VARCHAR2
,p_gl_balancing_segment_name       IN VARCHAR2
,p_gl_account_segment_name         IN VARCHAR2
,p_gl_intercompany_segment_name    IN VARCHAR2
,p_gl_management_segment_name      IN VARCHAR2
,p_fa_cost_ctr_segment_name        IN VARCHAR2
,p_validation_date                 IN DATE $parameters$
)
RETURN NUMBER
PARALLEL_ENABLE;
';


C_ADR_CCID_TAD_FUNCT_BODY        CONSTANT      VARCHAR2(10000):= '
---------------------------------------
--
-- PUBLIC FUNCTION
--         get_ccid_$adr_hash_id$
--
---------------------------------------
FUNCTION get_ccid_$adr_hash_id$ (
 p_mode                            IN VARCHAR2
,p_rowid                           IN UROWID
,p_line_index                      IN NUMBER
,p_chart_of_accounts_id            IN NUMBER
,p_chart_of_accounts_name          IN VARCHAR2
,p_gl_balancing_segment_name       IN VARCHAR2
,p_gl_account_segment_name         IN VARCHAR2
,p_gl_intercompany_segment_name    IN VARCHAR2
,p_gl_management_segment_name      IN VARCHAR2
,p_fa_cost_ctr_segment_name        IN VARCHAR2
,p_validation_date                 IN DATE $parameters$
)
RETURN NUMBER
IS
l_return_value NUMBER;
l_log_module VARCHAR2(2000);
BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||''.get_ccid_$adr_hash_id$'';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         ( p_module   => l_log_module
          ,p_msg      => ''BEGIN of get_ccid_$adr_hash_id$''
          ,p_level    => C_LEVEL_PROCEDURE);

END IF;

$adr_body$

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         ( p_module   => l_log_module
          ,p_msg      => ''END of get_ccid_$adr_hash_id$''
          ,p_level    => C_LEVEL_PROCEDURE);

END IF;

log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_CCID_NO_VALUE''
                 ,p_token_name_1   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_1  => ''$ADR_NAME$''
                );
RETURN NULL;

EXCEPTION
WHEN OTHERS
THEN
   log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_ADR_GENERIC_EXCEPTION''
                 ,p_token_name_1   => ''FUNCTION_NAME''
                 ,p_token_value_1  => ''$TAD_PACKAGE_NAME_3$.get_ccid_$adr_hash_id$ ''
                 ,p_token_name_2   => ''ERROR''
                 ,p_token_value_2  => SQLERRM
                 ,p_token_name_3   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_3  => ''$ADR_NAME$''
                );
   RETURN NULL;
END get_ccid_$adr_hash_id$;
';

C_ADR_SEGMENT_TAD_FUNCT_NAME        CONSTANT      VARCHAR2(50):=
   'get_segment_$adr_hash_id$';

C_ADR_SEGMENT_TAD_FUNCT_SPEC        CONSTANT      VARCHAR2(10000):= '
---------------------------------------
--
-- PUBLIC FUNCTION
--         get_segment_$adr_hash_id$
--
---------------------------------------
FUNCTION '|| C_ADR_SEGMENT_TAD_FUNCT_NAME || ' (
 p_mode                            IN VARCHAR2
,p_rowid                           IN UROWID
,p_line_index                      IN NUMBER
,p_chart_of_accounts_id            IN NUMBER
,p_chart_of_accounts_name          IN VARCHAR2
,p_gl_balancing_segment_name       IN VARCHAR2
,p_gl_account_segment_name         IN VARCHAR2
,p_gl_intercompany_segment_name    IN VARCHAR2
,p_gl_management_segment_name      IN VARCHAR2
,p_fa_cost_ctr_segment_name        IN VARCHAR2
,p_validation_date                 IN DATE $parameters$
)
RETURN VARCHAR2
PARALLEL_ENABLE;
';


C_ADR_SEGMENT_TAD_FUNCT_BODY        CONSTANT      VARCHAR2(10000):= '
---------------------------------------
--
-- PUBLIC FUNCTION
--         get_segment_$adr_hash_id$
--
---------------------------------------
FUNCTION get_segment_$adr_hash_id$ (
 p_mode                            IN VARCHAR2
,p_rowid                           IN UROWID
,p_line_index                      IN NUMBER
,p_chart_of_accounts_id            IN NUMBER
,p_chart_of_accounts_name          IN VARCHAR2
,p_gl_balancing_segment_name       IN VARCHAR2
,p_gl_account_segment_name         IN VARCHAR2
,p_gl_intercompany_segment_name    IN VARCHAR2
,p_gl_management_segment_name      IN VARCHAR2
,p_fa_cost_ctr_segment_name        IN VARCHAR2
,p_validation_date                 IN DATE $parameters$
)
RETURN VARCHAR2
IS
l_component_type       VARCHAR2(80);
l_component_code       VARCHAR2(30);
l_component_type_code  VARCHAR2(1);
l_component_appl_id    INTEGER;
l_amb_context_code     VARCHAR2(30);
l_return_value         VARCHAR2(30);

l_log_module           VARCHAR2(2000);

BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||''.get_segment_$adr_hash_id$'';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         ( p_module   => l_log_module
          ,p_msg      => ''BEGIN of get_segment_$adr_hash_id$''
          ,p_level    => C_LEVEL_PROCEDURE);

END IF;

l_component_type         := ''AMB_ADR'';
l_component_code         := ''$adr_code$'';
l_component_type_code    := ''$adr_type_code$'';
l_component_appl_id      :=  $adr_appl_id$;
l_amb_context_code       := ''$amb_context_code$'';

$adr_body$

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         ( p_module   => l_log_module
          ,p_msg      => ''END of get_segment_$adr_hash_id$''
          ,p_level    => C_LEVEL_PROCEDURE);

END IF;

log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_NO_VALUE''
                 ,p_token_name_1   => ''FUNCTION_NAME''
                 ,p_token_value_1  => ''$TAD_PACKAGE_NAME_3$.get_ccid_$adr_hash_id$ ''
                 ,p_token_name_2   => ''ADR_NAME''
                 ,p_token_value_2  => ''$ADR_NAME$''
                );

RETURN NULL;

EXCEPTION
WHEN OTHERS
THEN
    log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_ADR_GENERIC_EXCEPTION''
                 ,p_token_name_1   => ''FUNCTION_NAME''
                 ,p_token_value_1  => ''$TAD_PACKAGE_NAME_3$.get_segment_$adr_hash_id$ ''
                 ,p_token_name_2   => ''ERROR''
                 ,p_token_value_2  => SQLERRM
                 ,p_token_name_3   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_3  => ''$ADR_NAME$''
                );

END get_segment_$adr_hash_id$;
';


--
-- Insert source CCID
--
C_TAD_CCID_S                         CONSTANT       VARCHAR2(10000):='
--The CCID comes from a source
RETURN TO_NUMBER($source$);
';
--
--
-- Insert constant CCID
--
C_TAD_CCID_C                         CONSTANT       VARCHAR2(10000):='
--The CCID is a constant value
RETURN TO_NUMBER($source$);
';
--
-- Insert Segment
--
C_TAD_SEGMENT                       CONSTANT       VARCHAR2(10000):='
RETURN TO_CHAR($source$);
';
--
--
--
C_TAD_FLEXFIELD_SEGMENT                     CONSTANT       VARCHAR2(10000):='
--
get_flexfield_segment(
   p_mode                            => p_mode
  ,p_rowid                           => p_rowid
  ,p_line_index                      => p_line_index
  ,p_chart_of_accounts_id            => p_chart_of_accounts_id
  ,p_chart_of_accounts_name          => p_chart_of_accounts_name
  ,p_ccid                            => $combination_id$
  ,p_source_code                     => ''$source_code$''
  ,p_source_type_code                => ''$source_type_code$''
  ,p_source_application_id           => $source_application_id$
  ,p_segment_name                    => ''$segment_code$''
  ,p_gl_balancing_segment_name       => p_gl_balancing_segment_name
  ,p_gl_account_segment_name         => p_gl_account_segment_name
  ,p_gl_intercompany_segment_name    => p_gl_intercompany_segment_name
  ,p_gl_management_segment_name      => p_gl_management_segment_name
  ,p_fa_cost_ctr_segment_name        => p_fa_cost_ctr_segment_name
  ,p_adr_name                        => ''$ADR_NAME$''
)'
;

--
-- Mapping Set to get CCID value
--
C_TAD_MAPPING_CCID           CONSTANT       VARCHAR2(10000):='
BEGIN
    --The CCID comes from a mapping set
    SELECT value_code_combination_id
      INTO l_return_value
      FROM
    ( SELECT value_code_combination_id
        FROM
       (
        SELECT 1 priority
              ,xmsv.value_code_combination_id
              ,xmsv.input_value_type_code
          FROM xla_mapping_set_values  xmsv
         WHERE xmsv.mapping_set_code    = ''$mapping_set_code$''
           AND  ( TRUNC(p_validation_date)  BETWEEN NVL(xmsv.effective_date_from,p_validation_date)
                                     AND NVL(xmsv.effective_date_to,p_validation_date) )

           AND xmsv.input_value_type_code  =''I''
           AND xmsv.input_value_constant = TO_CHAR($input_source$)
           AND enabled_flag = ''Y''
       UNION
        SELECT 2 priority
              ,xmsv.value_code_combination_id
              ,xmsv.input_value_type_code
           FROM  xla_mapping_set_values  xmsv
          WHERE  xmsv.mapping_set_code    = ''$mapping_set_code$''
            AND  ( TRUNC(p_validation_date)  BETWEEN NVL(xmsv.effective_date_from,p_validation_date)
                                     AND NVL(xmsv.effective_date_to,p_validation_date) )
            AND xmsv.input_value_type_code = ''D''
            AND enabled_flag = ''Y''
       )
       ORDER BY priority
    )
    WHERE ROWNUM = 1;
    RETURN l_return_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_CCID_NO_VALUE''
                 ,p_token_name_1   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_1  => ''$ADR_NAME$''
                );

        log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_NO_MAPPING''
                 ,p_token_name_1   => ''MAPPING_NAME''
                 ,p_token_value_1  => ''$mapping_set_code$''
                 ,p_token_name_2   => ''SEGMENT_VALUE''
                 ,p_token_value_2  => $input_source$
                );
        RETURN NULL;
END;
';
--
--
-- Mapping Set, to get segment value
--
C_TAD_MAPPING_SEGMENT        CONSTANT       VARCHAR2(10000):='
BEGIN
--The CCID comes from a mapping set
    SELECT value_constant
      INTO l_return_value
      FROM
    ( SELECT value_constant
        FROM
       (
        SELECT 1 priority
              ,xmsv.value_constant
              ,xmsv.input_value_type_code
          FROM xla_mapping_set_values  xmsv
         WHERE xmsv.mapping_set_code    = ''$mapping_set_code$''
           AND  ( TRUNC(p_validation_date)  BETWEEN NVL(xmsv.effective_date_from,p_validation_date)
                                     AND NVL(xmsv.effective_date_to,p_validation_date) )

           AND xmsv.input_value_type_code  =''I''
           AND xmsv.input_value_constant = TO_CHAR($input_source$)
           AND enabled_flag = ''Y''
       UNION
        SELECT 2 priority
              ,xmsv.value_constant
              ,xmsv.input_value_type_code
           FROM  xla_mapping_set_values  xmsv
          WHERE  xmsv.mapping_set_code    = ''$mapping_set_code$''
            AND  ( TRUNC(p_validation_date)  BETWEEN NVL(xmsv.effective_date_from,p_validation_date)
                                     AND NVL(xmsv.effective_date_to,p_validation_date) )
            AND xmsv.input_value_type_code = ''D''
            AND enabled_flag = ''Y''
       )
       ORDER BY priority
    )
    WHERE ROWNUM = 1;
    RETURN l_return_value;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_CCID_NO_VALUE''
                 ,p_token_name_1   => ''SEGMENT_RULE_NAME''
                 ,p_token_value_1  => ''$ADR_NAME$''
                );

        log_error (
                  p_mode           => p_mode
                 ,p_rowid          => p_rowid
                 ,p_line_index     => p_line_index
                 ,p_msg_name       => ''XLA_TAB_GET_SEG_NO_MAPPING''
                 ,p_token_name_1   => ''MAPPING_NAME''
                 ,p_token_value_1  => ''$mapping_set_code$''
                 ,p_token_name_2   => ''SEGMENT_VALUE''
                 ,p_token_value_2  => $input_source$
                );
        RETURN NULL;
END;
';

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
--               *********** Local Trace Routine **********
--=============================================================================

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_adr_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           ( p_msg                        IN VARCHAR2
           , p_level                      IN NUMBER
           , p_module                     IN VARCHAR2)
IS
BEGIN
----------------------------------------------------------------------------
-- Following is for FND log.
----------------------------------------------------------------------------
IF (p_msg IS NULL AND p_level >= g_log_level) THEN
          fnd_log.message(p_level, p_module );
ELSIF p_level >= g_log_level THEN
          fnd_log.string(p_level , p_module , p_msg);
END IF;

EXCEPTION
       WHEN xla_exceptions_pkg.application_exception THEN
          RAISE;
       WHEN OTHERS THEN
          xla_exceptions_pkg.raise_message
             (p_location   => 'xla_cmp_adr_pkg.trace');
END trace;

/*------------------------------------------------------------+
|                                                             |
|  Private function                                           |
|                                                             |
|       generate_adr_seg_detail                               |
|                                                             |
|  Translates each ADR segment row into PL/SQL code           |
|                                                             |
+------------------------------------------------------------*/

/*-------------------------------------------------------------------------------+
|                                                                                |
|   BNF: ADR segment detail                                                      |
|                                                                                |
|   <segment_detail>  := <key_flexfield_segment>                                 |
|                     |  <key_flexfield>   <segment_code>                        |
|                     |  <constant >                                             |
|                     |  <mapping_set_code> <input_key_flexfield_segment>        |
|                     |  <mapping_set_code> <input_key_flexfield> <segment_code> |
|                     ;                                                          |
|                                                                                |
+-------------------------------------------------------------------------------*/

FUNCTION generate_adr_seg_detail (
  p_value_type_code            IN VARCHAR2
, p_value_source_appl_id       IN NUMBER
, p_value_source_type_code     IN VARCHAR2
, p_value_source_code          IN VARCHAR2
, p_value_constant             IN VARCHAR2
, p_value_mapping_set_code     IN VARCHAR2
, p_value_flexfield_segment    IN VARCHAR2
, p_input_source_appl_id       IN NUMBER
, p_input_source_type_code     IN VARCHAR2
, p_input_source_code          IN VARCHAR2
, p_array_adr_source_index     IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS

C_RETURN_SEGMENT                     CONSTANT  VARCHAR2(10000):=
'--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := $code_combination_id$ ;
  x_value_segment_code    := $value_segment_code$ ;
  x_value_type_code       := ''$value_type_code$'';
  l_output_value          := $source$;
  RETURN l_output_value;
';

C_RETURN_NULL_SEGMENT                     CONSTANT  VARCHAR2(10000):=
'--
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

  END IF;
  x_value_combination_id  := null;
  x_value_segment_code    := null;
  x_value_type_code       := null;
  l_output_value          := null;
  RETURN l_output_value;
';

C_KEY_FLEXFIELD_SEGMENT        CONSTANT       VARCHAR2(10000):='
xla_ae_code_combination_pkg.get_flex_segment_value(
   p_combination_id          =>  $combination_id$
  ,p_segment_code            => ''$segment_code$''
  ,p_id_flex_code            => ''$id_flex_code$''
  ,p_flex_application_id     => $flexfield_appl_id$
  ,p_application_short_name  => ''$appl_short_name$''
  ,p_source_code             => ''$source_code$''
  ,p_source_type_code        => ''$source_type_code$''
  ,p_source_application_id   => $source_application_id$
  ,p_component_type          => l_component_type
  ,p_component_code          => l_component_code
  ,p_component_type_code     => l_component_type_code
  ,p_component_appl_id       => l_component_appl_id
  ,p_amb_context_code        => l_amb_context_code
  ,p_entity_code             => NULL
  ,p_event_class_code        => NULL
  ,p_ae_header_id            => NULL
)'
;

--
-- Mapping Set, to get segment value
--
C_MAPPING_SEGMENT        CONSTANT       VARCHAR2(10000):='
xla_ae_sources_pkg.get_mapping_flexfield_char (
   p_component_type       => l_component_type
 , p_component_code       => l_component_code
 , p_component_type_code  => l_component_type_code
 , p_component_appl_id    => l_component_appl_id
 , p_amb_context_code     => l_amb_context_code
 , p_mapping_set_code     => ''$mapping_set_code$''
 , p_input_constant       => TO_CHAR($input_source$)
 , p_ae_header_id         => p_ae_header_id
 )'
 ;

l_Idx              BINARY_INTEGER;
l_detail           VARCHAR2(32000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_seg_detail';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of generate_adr_seg_detail'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_value_type_code = ' ||p_value_type_code||
                        ' - p_value_source_appl_id= '||p_value_source_appl_id||
                        ' - p_value_source_type_code= '||p_value_source_type_code||
                        ' - p_value_source_code= '||p_value_source_code||
                        ' - p_value_constant= '||p_value_constant||
                        ' - p_value_mapping_set_code= '||p_value_mapping_set_code||
                        ' - p_value_flexfield_segment= '||p_value_flexfield_segment||
                        ' - p_input_source_appl_id= '||p_input_source_appl_id||
                        ' - p_input_source_type_code= '||p_input_source_type_code||
                        ' - p_input_source_code= '||p_input_source_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

IF   g_component_type  = 'TAB_ADR' THEN
  l_detail :=NULL;
ELSE
  l_detail := C_RETURN_NULL_SEGMENT;
END IF;

IF p_value_type_code= 'S'                AND
   p_value_source_appl_id    IS NOT NULL AND
   p_value_source_type_code  IS NOT NULL AND
   p_value_source_code       IS NOT NULL
THEN
  -- source
  l_Idx := xla_cmp_source_pkg.StackSource (
                p_source_code                => p_value_source_code
              , p_source_type_code           => p_value_source_type_code
              , p_source_application_id      => p_value_source_appl_id
              , p_array_source_index         => p_array_adr_source_index
              , p_rec_sources                => p_rec_sources
              );

   IF   g_component_type  = 'TAB_ADR'
   THEN
      l_detail := C_TAD_SEGMENT;
   ELSE
      l_detail := C_RETURN_SEGMENT;
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',nvl(p_value_type_code,' '));

   END IF;

   IF p_value_flexfield_segment IS NULL THEN
     -- segment
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$',
                               nvl(xla_cmp_source_pkg.GenerateSource(
                                     p_Index                     => l_Idx
                                   , p_rec_sources               => p_rec_sources
                                   , p_translated_flag           => 'N'),' null')
                              );
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$code_combination_id$', ' null');
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_segment_code$', ' null');

   ELSE
     -- get segment from key flexfield
     IF   g_component_type  = 'TAB_ADR'
     THEN

      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$' , C_TAD_FLEXFIELD_SEGMENT);

      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$combination_id$', xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_translated_flag           => 'N')
                        );

      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$segment_code$'         ,p_value_flexfield_segment);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_code$'          ,p_rec_sources.array_source_code(l_Idx) );
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_type_code$'     ,p_rec_sources.array_source_type_code(l_Idx) );
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_application_id$',to_char(p_rec_sources.array_application_id(l_Idx)) );

     ELSE

        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$code_combination_id$', xla_cmp_source_pkg.GenerateSource(
                                     p_Index                     => l_Idx
                                   , p_rec_sources               => p_rec_sources
                                   , p_translated_flag           => 'N')
                                   );
        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_segment_code$', ''''||p_value_flexfield_segment||'''');
        l_detail  := xla_cmp_string_pkg.replace_token(l_detail ,'$source$' , ' null');

     END IF;

   END IF;

ELSIF p_value_type_code = 'C'  THEN
-- constant

     IF   g_component_type  = 'TAB_ADR' THEN
         l_detail := C_TAD_SEGMENT;
     ELSE
         l_detail := C_RETURN_SEGMENT;
         l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',p_value_type_code);
         l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$code_combination_id$', ' null');
         l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_segment_code$', ' null');
     END IF;

     IF p_value_constant IS NULL THEN
        l_detail := xla_cmp_string_pkg.replace_token(l_detail,'$source$' , ' null') ;
     ELSE
        l_detail := xla_cmp_string_pkg.replace_token(l_detail,'$source$' , ''''||p_value_constant||'''') ;
     END IF;

ELSIF  p_value_type_code = 'M' AND
       p_value_mapping_set_code      IS NOT NULL AND
       p_input_source_code           IS NOT NULL AND
       p_input_source_type_code      IS NOT NULL AND
       p_input_source_appl_id        IS NOT NULL
THEN
-- Mapping set
   l_Idx := xla_cmp_source_pkg.StackSource (
                p_source_code                => p_input_source_code
              , p_source_type_code           => p_input_source_type_code
              , p_source_application_id      => p_input_source_appl_id
              , p_array_source_index         => p_array_adr_source_index
              , p_rec_sources                => p_rec_sources
              );

   IF   g_component_type  = 'TAB_ADR'
   THEN
      l_detail := C_TAD_MAPPING_SEGMENT;
   ELSE
      l_detail := C_RETURN_SEGMENT;
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',p_value_type_code);

   END IF;

   IF p_value_flexfield_segment IS NULL THEN
      --segment mapping set
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$', C_MAPPING_SEGMENT);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$mapping_set_code$',p_value_mapping_set_code);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$input_source$',
                               xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_translated_flag           => 'N')
                             );
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$code_combination_id$', ' null');
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_segment_code$', ' null');

   ELSE
     --key flexfield mapping set
     IF   g_component_type  = 'TAB_ADR'
     THEN
        l_detail  := xla_cmp_string_pkg.replace_token(l_detail ,'$input_source$' , C_TAD_FLEXFIELD_SEGMENT);
     ELSE
        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$', C_MAPPING_SEGMENT);
        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$input_source$', C_KEY_FLEXFIELD_SEGMENT);
        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_segment_code$', ' null');
        l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$code_combination_id$', ' null');
     END IF;

     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$mapping_set_code$',p_value_mapping_set_code);
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$combination_id$', xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_translated_flag           => 'N')
                        );

     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$segment_code$'         ,p_value_flexfield_segment);
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$id_flex_code$'         ,p_rec_sources.array_id_flex_code(l_Idx));
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$flexfield_appl_id$'    ,to_char(p_rec_sources.array_flexfield_appl_id(l_Idx)) );
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$appl_short_name$'      ,p_rec_sources.array_appl_short_name(l_Idx));
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_code$'          ,p_rec_sources.array_source_code(l_Idx) );
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_type_code$'     ,p_rec_sources.array_source_type_code(l_Idx) );
     l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source_application_id$',to_char(p_rec_sources.array_application_id(l_Idx)) );

   END IF;

END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_adr_seg_detail ='||length(l_detail)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_detail;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_adr_seg_detail');
END generate_adr_seg_detail;


/*------------------------------------------------------------+
|                                                             |
|  Private function                                           |
|                                                             |
|       generate_adr_seg_detail                               |
|                                                             |
|  Translates each ADR flexfield(ccid) row into PL/SQL code   |
|                                                             |
+------------------------------------------------------------*/

/*-----------------------------------------------------------------------------+
|                                                                              |
|   BNF: ADR CCID detail                                                       |
|                                                                              |
|   <ccid_detail>  := <key_flexfield>                                          |
|                   |  <constant >                                             |
|                   |  <mapping_set_code> <input_key_flexfield>                |
|                   ;                                                          |
|                                                                              |
+-----------------------------------------------------------------------------*/

FUNCTION generate_adr_ccid_detail (
  p_value_type_code              IN VARCHAR2
, p_value_source_appl_id         IN NUMBER
, p_value_source_type_code       IN VARCHAR2
, p_value_source_code            IN VARCHAR2
, p_value_constant               IN VARCHAR2
, p_value_code_combination_id    IN NUMBER
, p_value_flexfield_segment      IN VARCHAR2
, p_value_mapping_set_code       IN VARCHAR2
, p_input_source_appl_id         IN NUMBER
, p_input_source_type_code       IN VARCHAR2
, p_input_source_code            IN VARCHAR2
, p_array_adr_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS

C_RETURN_CCID                     CONSTANT  VARCHAR2(10000):=
' --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := ''$value_type_code$'';
  l_output_value    := TO_NUMBER($source$);
  RETURN l_output_value;
';

C_RETURN_NULL_CCID                     CONSTANT  VARCHAR2(10000):=
' --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''END of AcctDerRule_$adr_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := null;
  l_output_value    := null;
  RETURN l_output_value;
';


-- Mapping Set to get CCID value
--
C_MAPPING_CCID           CONSTANT       VARCHAR2(10000):='
xla_ae_sources_pkg.get_mapping_flexfield_number (
   p_component_type       => l_component_type
 , p_component_code       => l_component_code
 , p_component_type_code  => l_component_type_code
 , p_component_appl_id    => l_component_appl_id
 , p_amb_context_code     => l_amb_context_code
 , p_mapping_set_code     => ''$mapping_set_code$''
 , p_input_constant       => TO_CHAR($input_source$)
 , p_ae_header_id          => p_ae_header_id
 )'
 ;
--

l_Idx              BINARY_INTEGER;
l_detail           CLOB;
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_ccid_detail';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_adr_ccid_detail'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_value_type_code = ' ||p_value_type_code||
                        ' - p_value_source_appl_id= '||p_value_source_appl_id||
                        ' - p_value_source_type_code= '||p_value_source_type_code||
                        ' - p_value_source_code= '||p_value_source_code||
                        ' - p_value_constant= '||p_value_constant||
                        ' - p_value_code_combination_id= '||p_value_code_combination_id||
                        ' - p_value_flexfield_segment= '||p_value_flexfield_segment||
                        ' - p_value_mapping_set_code ='||p_value_mapping_set_code||
                        ' - p_input_source_appl_id= '||p_input_source_appl_id||
                        ' - p_input_source_type_code= '||p_input_source_type_code||
                        ' - p_input_source_code= '||p_input_source_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;



IF   g_component_type  = 'TAB_ADR' THEN
 l_detail := null;
ELSE
 l_detail := C_RETURN_NULL_CCID;
END IF;

IF p_value_type_code = 'S'    AND
   p_value_source_code        IS NOT NULL AND
   p_value_source_type_code   IS NOT NULL AND
   p_value_source_appl_id     IS NOT NULL
THEN
--source
       l_Idx := xla_cmp_source_pkg.StackSource (
                p_source_code                => p_value_source_code
              , p_source_type_code           => p_value_source_type_code
              , p_source_application_id      => p_value_source_appl_id
              , p_array_source_index         => p_array_adr_source_index
              , p_rec_sources                => p_rec_sources
              );


      IF   g_component_type  = 'TAB_ADR' THEN
         l_detail := C_TAD_CCID_S;
      ELSE
         l_detail := C_RETURN_CCID;
         l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',p_value_type_code);
      END IF;

      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$',
                                 xla_cmp_source_pkg.GenerateSource(
                                   p_Index                     => l_Idx
                                 , p_rec_sources                => p_rec_sources
                                 , p_translated_flag           => 'N')
                                   );

ELSIF p_value_type_code = 'C'
THEN
--constant

   IF  g_component_type  = 'TAB_ADR'
   THEN
      l_detail := C_TAD_CCID_C;
   ELSE
      l_detail := C_RETURN_CCID;
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',p_value_type_code);
   END IF;

   IF p_value_code_combination_id IS NULL THEN
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$', 'null');
   ELSE
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$', to_char(p_value_code_combination_id));
   END IF;

ELSIF  p_value_type_code             = 'M'       AND
       p_value_mapping_set_code      IS NOT NULL AND
       p_input_source_code           IS NOT NULL AND
       p_input_source_type_code      IS NOT NULL AND
       p_input_source_appl_id        IS NOT NULL
THEN
-- Mapping set

   l_Idx := xla_cmp_source_pkg.StackSource (
                p_source_code                => p_input_source_code
              , p_source_type_code           => p_input_source_type_code
              , p_source_application_id      => p_input_source_appl_id
              , p_array_source_index         => p_array_adr_source_index
              , p_rec_sources                => p_rec_sources
              );

   IF   g_component_type  = 'TAB_ADR'
   THEN
      l_detail := C_TAD_MAPPING_CCID;
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$mapping_set_code$',p_value_mapping_set_code);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$input_source$',
                               xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_translated_flag           => 'N')
                         );

   ELSE
      --AAD
      l_detail := C_RETURN_CCID;
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$value_type_code$',p_value_type_code);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$source$', C_MAPPING_CCID );
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$mapping_set_code$',p_value_mapping_set_code);
      l_detail := xla_cmp_string_pkg.replace_token(l_detail ,'$input_source$',
                               xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_translated_flag           => 'N')
                         );
   END IF;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_adr_ccid_detail ='||length(l_detail)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_detail;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_adr_ccid_detail');
END generate_adr_ccid_detail;

/*------------------------------------------------------------+
|                                                             |
|  Private function                                           |
|                                                             |
|       generate_attached_adr_detail                          |
|                                                             |
|  Translates each attached adr row into PL/SQL code          |
|                                                             |
+------------------------------------------------------------*/
FUNCTION generate_attached_adr_detail(
  p_amb_context_code             IN VARCHAR2
, p_value_segment_rule_appl_id   IN NUMBER
, p_value_segment_rule_type_code IN VARCHAR2
, p_value_segment_rule_code      IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_array_adr_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
   l_details            CLOB;
   l_detail             CLOB;
   l_cond               CLOB;
   l_endif              BOOLEAN;
   l_first              BOOLEAN;
   l_log_module         VARCHAR2(240);
   l_adr_name           VARCHAR2(80);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_attached_adr_detail';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_attached_adr_detail'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_endif      := TRUE;
l_first      := TRUE;
l_details    := null;
l_cond       := null;
l_detail     := null;

--
-- Retrieve ADR Name
--
SELECT NAME
  INTO l_adr_name
  FROM xla_seg_rules_tl
 WHERE application_id         = p_value_segment_rule_appl_id
   AND amb_context_code       = p_amb_context_code
   AND segment_rule_type_code = p_value_segment_rule_type_code
   AND segment_rule_code      = p_value_segment_rule_code
   AND language               = userenv('LANG');

--
-- Retrieve ADR Details
--
FOR adr_detail_rec IN ( SELECT  xsrd.value_type_code
                              , xsrd.value_source_application_id
                              , xsrd.value_source_type_code
                              , xsrd.value_source_code
                              , xsrd.value_constant
                              , xsrd.value_code_combination_id
                              , xsrd.value_mapping_set_code
                              , xsrd.value_flexfield_segment_code
                              , xsrd.input_source_application_id
                              , xsrd.input_source_type_code
                              , xsrd.input_source_code
                              , xsrd.segment_rule_detail_id
                              , xsrd.user_sequence
                          FROM  xla_seg_rule_details         xsrd
                         WHERE xsrd.application_id         = p_value_segment_rule_appl_id
                           AND xsrd.segment_rule_code      = p_value_segment_rule_code
                           AND xsrd.segment_rule_type_code = p_value_segment_rule_type_code
                           AND xsrd.amb_context_code       = p_amb_context_code
                         ORDER BY xsrd.user_sequence  -- priority
                        ) LOOP

  l_detail := NULL;

  IF ( p_flexfield_assign_mode ='A') THEN
      -- accounting flexfield adr detail
      l_detail := generate_adr_ccid_detail(
             p_value_type_code                  => adr_detail_rec.value_type_code
           , p_value_source_appl_id             => adr_detail_rec.value_source_application_id
           , p_value_source_type_code           => adr_detail_rec.value_source_type_code
           , p_value_source_code                => adr_detail_rec.value_source_code
           , p_value_constant                   => adr_detail_rec.value_constant
           , p_value_code_combination_id        => adr_detail_rec.value_code_combination_id
           , p_value_flexfield_segment          => adr_detail_rec.value_flexfield_segment_code
           , p_value_mapping_set_code           => adr_detail_rec.value_mapping_set_code
           , p_input_source_appl_id             => adr_detail_rec.input_source_application_id
           , p_input_source_type_code           => adr_detail_rec.input_source_type_code
           , p_input_source_code                => adr_detail_rec.input_source_code
           , p_array_adr_source_index           => p_array_adr_source_index
           , p_rec_sources                      => p_rec_sources
           );

   ELSIF (p_flexfield_assign_mode ='S' OR p_flexfield_assign_mode = 'V') THEN
         -- segment or value set adr detail
      l_detail := generate_adr_seg_detail(
             p_value_type_code                  => adr_detail_rec.value_type_code
           , p_value_source_appl_id             => adr_detail_rec.value_source_application_id
           , p_value_source_type_code           => adr_detail_rec.value_source_type_code
           , p_value_source_code                => adr_detail_rec.value_source_code
           , p_value_constant                   => adr_detail_rec.value_constant
           , p_value_mapping_set_code           => adr_detail_rec.value_mapping_set_code
           , p_value_flexfield_segment          => adr_detail_rec.value_flexfield_segment_code
           --
           , p_input_source_appl_id             => adr_detail_rec.input_source_application_id
           , p_input_source_type_code           => adr_detail_rec.input_source_type_code
           , p_input_source_code                => adr_detail_rec.input_source_code
           --
           , p_array_adr_source_index           => p_array_adr_source_index
           --
           , p_rec_sources                      => p_rec_sources
           );

   END IF;

   l_cond := xla_cmp_condition_pkg.GetCondition   (
        p_application_id              => p_value_segment_rule_appl_id
       , p_component_type             => g_component_type
       , p_component_code             => p_value_segment_rule_code
       , p_component_type_code        => p_value_segment_rule_type_code
       , p_component_name             => NULL-- p_adr_name
       , p_amb_context_code           => p_amb_context_code
       , p_segment_rule_detail_id     => adr_detail_rec.segment_rule_detail_id
       , p_array_cond_source_index    => p_array_adr_source_index
       , p_rec_sources                => p_rec_sources
       );

   IF l_cond IS NULL THEN
    -- no condition
        IF l_endif THEN

           l_details   := l_details ||g_chr_newline||l_detail;
        ELSE
           l_endif   := TRUE;
           l_first   := TRUE;

           l_details := l_details ||g_chr_newline||'END IF;'||g_chr_newline;
           l_details := l_details ||g_chr_newline||l_detail;
       END IF;
   ELSE
    --condition
        IF l_first THEN

           l_details := l_details ||g_chr_newline||' IF '||l_cond||' THEN ';
           l_details := l_details ||g_chr_newline||l_detail;
           l_first   := FALSE;
           l_endif   := FALSE;
        ELSE

           l_details := l_details ||g_chr_newline||' ELSIF '||l_cond||' THEN ';
           l_details := l_details ||g_chr_newline||l_detail;
           l_endif   := FALSE;
        END IF;
   END IF;
END LOOP;

IF NOT l_endif and l_details IS NOT NULL THEN
  l_details := l_details ||g_chr_newline||' END IF;';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_attached_adr_detail'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_details;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_attached_adr_detail');

END generate_attached_adr_detail;

/*------------------------------------------------------------+
|                                                             |
|  Private function                                           |
|                                                             |
|       generate_adr_body                                     |
|                                                             |
|  Generates AcctDerRule_XX() body function from the ADR      |
|                                                             |
+------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------+
|                                                                                      |
|   BNF: ADR body                                                                      |
|                                                                                      |
|   <adr_body> := <list_of_acounting_flexfield_adr>                                    |
|               | <segment_or_value_set_adr>                                           |
|               ;                                                                      |
|                                                                                      |
|  <acounting_flexfield_adr> := <list_of_ccid_detail> <condition> <ccid_detail>        |
|                            | <list_of_ccid_detail> <ccid_detail>                     |
|                            | <condition> <ccid_detail>                               |
|                            | <ccid_detail>                                           |
|                            ;                                                         |
|                                                                                      |
|  <segment_or_value_set_adr> := <list_of_segment_detail> <condition> <segment_detail> |
|                             | <list_of_segment_detail> <condition> <segment_detail>  |
|                             | <condition> <segment_detail>                           |
|                             | <segment_detail>                                       |
|                             ;                                                        |
+-------------------------------------------------------------------------------------*/

FUNCTION generate_adr_body   (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_segment_rule_code            IN VARCHAR2
, p_segment_rule_type_code       IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_adr_name                     IN VARCHAR2
, p_array_adr_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS
l_adr                CLOB;
l_detail             CLOB;
l_cond               CLOB;
l_endif              BOOLEAN;
l_first              BOOLEAN;
l_IsCompiled         BOOLEAN;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_body';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_adr_body'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_IsCompiled := FALSE;
l_endif      := TRUE;
l_first      := TRUE;
l_adr        := null;
l_cond       := null;
l_detail     := null;

FOR adr_detail_rec IN ( SELECT  xsrd.value_type_code
                              , xsrd.value_source_application_id
                              , xsrd.value_source_type_code
                              , xsrd.value_source_code
                              , xsrd.value_constant
                              , xsrd.value_code_combination_id
                              , xsrd.value_mapping_set_code
                              , xsrd.value_flexfield_segment_code
                              , xsrd.value_segment_rule_appl_id
                              , xsrd.value_segment_rule_type_code
                              , xsrd.value_segment_rule_code
                              , xsrd.input_source_application_id
                              , xsrd.input_source_type_code
                              , xsrd.input_source_code
                              , xsrd.segment_rule_detail_id
                              , xsrd.user_sequence
                          FROM  xla_seg_rule_details               xsrd
                         WHERE xsrd.application_id         = p_application_id
                           AND xsrd.segment_rule_code      = p_segment_rule_code
                           AND xsrd.segment_rule_type_code = p_segment_rule_type_code
                           AND xsrd.amb_context_code       = p_amb_context_code
                         ORDER BY xsrd.user_sequence  -- priority
                        ) LOOP



  l_detail := NULL;

  --
  -- If an ADR is attached, use the attached ADR information.
  --
  IF adr_detail_rec.value_segment_rule_appl_id IS NOT NULL THEN

     l_detail := generate_attached_adr_detail(
         p_amb_context_code               => p_amb_context_code
       , p_value_segment_rule_appl_id     => adr_detail_rec.value_segment_rule_appl_id
       , p_value_segment_rule_type_code   => adr_detail_rec.value_segment_rule_type_code
       , p_value_segment_rule_code        => adr_detail_rec.value_segment_rule_code
       , p_flexfield_assign_mode          => p_flexfield_assign_mode
       , p_array_adr_source_index         => p_array_adr_source_index
       , p_rec_sources                    => p_rec_sources);
  ELSE
     IF ( p_flexfield_assign_mode ='A') THEN
         -- accounting flexfield adr detail
         l_detail := generate_adr_ccid_detail(
             p_value_type_code                  => adr_detail_rec.value_type_code
           , p_value_source_appl_id             => adr_detail_rec.value_source_application_id
           , p_value_source_type_code           => adr_detail_rec.value_source_type_code
           , p_value_source_code                => adr_detail_rec.value_source_code
           , p_value_constant                   => adr_detail_rec.value_constant
           , p_value_code_combination_id        => adr_detail_rec.value_code_combination_id
           , p_value_flexfield_segment          => adr_detail_rec.value_flexfield_segment_code
           , p_value_mapping_set_code           => adr_detail_rec.value_mapping_set_code
           , p_input_source_appl_id             => adr_detail_rec.input_source_application_id
           , p_input_source_type_code           => adr_detail_rec.input_source_type_code
           , p_input_source_code                => adr_detail_rec.input_source_code
           , p_array_adr_source_index           => p_array_adr_source_index
           , p_rec_sources                      => p_rec_sources
           );

      ELSIF (p_flexfield_assign_mode ='S' OR p_flexfield_assign_mode = 'V') THEN
         -- segment or value set adr detail
            l_detail := generate_adr_seg_detail(
             p_value_type_code                  => adr_detail_rec.value_type_code
           , p_value_source_appl_id             => adr_detail_rec.value_source_application_id
           , p_value_source_type_code           => adr_detail_rec.value_source_type_code
           , p_value_source_code                => adr_detail_rec.value_source_code
           , p_value_constant                   => adr_detail_rec.value_constant
           , p_value_mapping_set_code           => adr_detail_rec.value_mapping_set_code
           , p_value_flexfield_segment          => adr_detail_rec.value_flexfield_segment_code
           --
           , p_input_source_appl_id             => adr_detail_rec.input_source_application_id
           , p_input_source_type_code           => adr_detail_rec.input_source_type_code
           , p_input_source_code                => adr_detail_rec.input_source_code
           --
           , p_array_adr_source_index           => p_array_adr_source_index
           --
           , p_rec_sources                      => p_rec_sources
           );

      END IF;
   END IF;

   l_cond := xla_cmp_condition_pkg.GetCondition   (
        p_application_id              => p_application_id
       , p_component_type             => g_component_type
       , p_component_code             => p_segment_rule_code
       , p_component_type_code        => p_segment_rule_type_code
       , p_component_name             => p_adr_name
       , p_amb_context_code           => p_amb_context_code
       , p_segment_rule_detail_id     => adr_detail_rec.segment_rule_detail_id
       , p_array_cond_source_index    => p_array_adr_source_index
       , p_rec_sources                => p_rec_sources
       );

   IF l_cond IS NULL THEN
    -- no condition
        IF l_endif THEN
           l_adr   := l_adr ||g_chr_newline||l_detail;
        ELSE
           l_endif  := TRUE;
           l_first  := TRUE;
           l_adr   := l_adr ||g_chr_newline||'END IF;'||g_chr_newline;
           l_adr   := l_adr ||g_chr_newline||l_detail;
       END IF;
   ELSE
    --condition
        IF l_first THEN
           l_adr     := l_adr ||g_chr_newline||' IF '||l_cond||' THEN ';
           l_adr     := l_adr ||g_chr_newline||l_detail;
           l_first   := FALSE;
           l_endif   := FALSE;
        ELSE
            l_adr     := l_adr ||g_chr_newline||' ELSIF '||l_cond||' THEN ';
            l_adr     := l_adr ||g_chr_newline||l_detail;
            l_endif   := FALSE;
        END IF;
   END IF;
END LOOP;

IF NOT l_endif and l_adr IS NOT NULL THEN
  IF p_flexfield_assign_mode = 'A' OR g_component_type = 'TAB_ADR' THEN
     l_adr := l_adr ||g_chr_newline||' END IF;';
  ELSE
     l_adr := l_adr ||g_chr_newline||' ELSE '
                    ||g_chr_newline||'    IF p_override_seg_flag = ''Y'' THEN '
                    ||g_chr_newline||'       RETURN ''#$NO_OVERRIDE#$'';'     -- 4465612
                    ||g_chr_newline||'    END IF;'
                    ||g_chr_newline||' END IF;';
  END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_adr_body'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_IsCompiled := TRUE;
RETURN l_adr;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        p_IsCompiled := FALSE;
        RETURN NULL;
   WHEN OTHERS THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_adr_body');
END generate_adr_body;

/*-------------------------------------------------------------+
|                                                              |
|  Private function                                            |
|                                                              |
|       generate_adr_function                                  |
|                                                              |
|  Generates AcctDerRule_XX() function from the ADR definition |
|                                                              |
+-------------------------------------------------------------*/

/*---------------------------------------------------+
|                                                    |
|   BNF: ADR body                                    |
|                                                    |
|   <adr> := <adr_header> <adr_body> <adr_end>       |
|          ;                                         |
|                                                    |
+----------------------------------------------------*/

FUNCTION generate_adr_function(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_segment_rule_code            IN VARCHAR2
, p_segment_rule_type_code       IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_flexfield_segment_code       IN VARCHAR2
, p_flex_value_set_id            IN NUMBER
, p_transaction_coa_id           IN NUMBER
, p_accounting_coa_id            IN NUMBER
, p_adr_name                     IN VARCHAR2
, p_array_adr_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS
l_Adr                      CLOB;
l_log_module               VARCHAR2(240);
l_fatal_error_message_text VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_function';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_adr_function'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

--Select the correct template
IF   g_component_type  = 'TAB_ADR'
THEN
   --CCID rule
   IF p_flexfield_assign_mode = 'A'
   THEN
      l_Adr      := C_ADR_CCID_TAD_FUNCT_BODY;
   --Segment rule
   ELSIF p_flexfield_assign_mode = 'S'
   THEN
      l_Adr      := C_ADR_SEGMENT_TAD_FUNCT_BODY;
   ELSE
   --Value set rule,not handled
      l_fatal_error_message_text := 'Invalid p_flexfield_assign_mode: ' ||
                                    p_flexfield_assign_mode;
      RAISE ge_fatal_error;
   END IF;

ELSE
--AMB

   CASE p_flexfield_assign_mode
     WHEN 'A' THEN  l_Adr      := C_ADR_CCID    ;
     WHEN 'S' THEN  l_Adr      := C_ADR_SEGMENT ;
     WHEN 'V' THEN  l_Adr      := C_ADR_SEGMENT ;
     ELSE
      l_fatal_error_message_text := 'Invalid p_flexfield_assign_mode: ' ||
                                    p_flexfield_assign_mode;

       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||l_fatal_error_message_text
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);

       END IF;
       RETURN NULL;
    END CASE;

END IF;

IF p_flexfield_segment_code IS NULL THEN
   l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr, '$flexfield_segment_code$',' null');   -- 4417664
ELSE
   l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$flexfield_segment_code$', ''''||p_flexfield_segment_code||'''');  -- 4417664
END IF;

IF p_flex_value_set_id IS NULL THEN
   l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr, '$flex_value_set_id$',' null');   -- 4417664
ELSE
   l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr, '$flex_value_set_id$', TO_CHAR(p_flex_value_set_id));   -- 4417664
END IF;

IF p_transaction_coa_id  IS NULL THEN
   l_Adr := xla_cmp_string_pkg.replace_token(l_Adr, '$transaction_coa_id$', ' null');  -- 4417664
 ELSE
   l_Adr := xla_cmp_string_pkg.replace_token(l_Adr, '$transaction_coa_id$', TO_CHAR(p_transaction_coa_id));  -- 4417664
END IF;

IF p_accounting_coa_id  IS NULL THEN
    l_Adr := xla_cmp_string_pkg.replace_token(l_Adr, '$accounting_coa_id$', ' null');  -- 4417664
ELSE l_Adr := xla_cmp_string_pkg.replace_token(l_Adr, '$accounting_coa_id$', TO_CHAR(p_accounting_coa_id));  -- 4417664
END IF;

l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$account_derivation_rule_code$' ,p_segment_rule_code);  -- 4417664
l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$adr_type_code$'     ,p_segment_rule_type_code);  -- 4417664
l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$adr_appl_id$'       ,TO_CHAR(p_application_id) );  -- 4417664
l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$amb_context_code$'  ,p_amb_context_code);  -- 4417664

l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr,'$adr_body$',
                      generate_adr_body (
                       p_application_id              => p_application_id
                     , p_amb_context_code            => p_amb_context_code
                     , p_segment_rule_code           => p_segment_rule_code
                     , p_segment_rule_type_code      => p_segment_rule_type_code
                     , p_flexfield_assign_mode       => p_flexfield_assign_mode
                     , p_adr_name                    => p_adr_name
                     , p_array_adr_source_index      => p_array_adr_source_index
                     , p_rec_sources                 => p_rec_sources
                     , p_IsCompiled                  => p_IsCompiled
                     )
                   );

IF g_component_type = 'TAB_ADR'
 THEN
    --Replace the ADR name
    l_Adr  := xla_cmp_string_pkg.replace_token(l_Adr    , '$ADR_NAME$'   , nvl(g_component_name,' ') );  -- 4417664
    l_Adr  := xla_cmp_string_pkg.replace_token(l_Adr , '$parameters$',
             xla_cmp_source_pkg.get_obj_parm_for_tab(
              p_array_source_index => p_array_adr_source_index
            , p_rec_sources        => p_rec_sources
            ));

 ELSE
    l_Adr  := xla_cmp_string_pkg.replace_token(l_Adr , '$parameters$',
             nvl(xla_cmp_source_pkg.GenerateParameters(
              p_array_source_index => p_array_adr_source_index
            , p_rec_sources        => p_rec_sources
            ),' '));
END IF;

IF   g_component_type  = 'TAB_ADR'
THEN

    l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$adr_hash_id$',TO_CHAR(
           xla_cmp_source_pkg.CacheAADObject (
               p_object                => xla_cmp_source_pkg.C_ADR
             , p_object_code           => p_segment_rule_code
             , p_object_type_code      => p_segment_rule_type_code
             , p_application_id        => p_application_id
             , p_event_class_code      => NULL
             , p_event_type_code       => NULL
             , p_array_source_index    => p_array_adr_source_index
             , p_rec_aad_objects       => p_rec_aad_objects
           )));  -- 4417664

ELSE

   l_Adr      := xla_cmp_string_pkg.replace_token(l_Adr ,'$adr_hash_id$',TO_CHAR(
           xla_cmp_source_pkg.CacheAADObject (
               p_object                => xla_cmp_source_pkg.C_ADR
             , p_object_code           => p_segment_rule_code
             , p_object_type_code      => p_segment_rule_type_code
             , p_application_id        => p_application_id
             , p_event_class_code      => NULL
             , p_event_type_code       => NULL
             , p_array_source_index    => p_array_adr_source_index
             , p_rec_aad_objects       => p_rec_aad_objects
           )));  -- 4417664

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_adr_function'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_Adr;
EXCEPTION
   WHEN ge_fatal_error
   THEN
      p_IsCompiled := FALSE;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
         trace
            (p_msg      => l_fatal_error_message_text
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RAISE;

   WHEN VALUE_ERROR THEN
        p_IsCompiled := FALSE;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled := FALSE;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_adr_function');
END generate_adr_function;

/*-------------------------------------------------------------+
|                                                              |
|  Private function                                            |
|                                                              |
|       generate_one_adr_fct                                   |
|                                                              |
|  Generates AcctDerRule_XX() function in DBMS_SQL.VARCHAR2S   |
|                                                              |
+-------------------------------------------------------------*/

FUNCTION generate_one_adr_fct(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_segment_rule_code            IN VARCHAR2
, p_segment_rule_type_code       IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_flexfield_segment_code       IN VARCHAR2
, p_flex_value_set_id            IN NUMBER
, p_transaction_coa_id           IN NUMBER
, p_accounting_coa_id            IN NUMBER
, p_adr_name                     IN VARCHAR2
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN  DBMS_SQL.VARCHAR2S
IS
--
l_array_adr_source_index         xla_cmp_source_pkg.t_array_ByInt;
l_array_null_adr_source_Idx      xla_cmp_source_pkg.t_array_ByInt;
--
l_adr_code       VARCHAR2(30);
l_Adr            CLOB;                   -- 4697330
l_array_adr      DBMS_SQL.VARCHAR2S;
l_log_module     VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_one_adr_fct';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_one_adr_fct'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_application_id = '||p_application_id ||
                        ' - p_segment_rule_code = '||p_segment_rule_code ||
                        ' - p_segment_rule_type_code = '||p_segment_rule_type_code ||
                        ' - p_flexfield_assign_mode = '||p_flexfield_assign_mode ||
                        ' - p_flexfield_segment_code = '||p_flexfield_segment_code ||
                        ' - p_flex_value_set_id = '||p_flex_value_set_id ||
                        ' - p_transaction_coa_id = '||p_transaction_coa_id ||
                        ' - p_adr_name = '||p_adr_name ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

--
-- init global variables
--
g_component_code      := p_segment_rule_code;
g_component_type_code := p_segment_rule_type_code;
g_component_appl_id   := p_application_id;
g_component_name      := p_adr_name;
g_amb_context_code    := p_amb_context_code;
--
l_array_adr           := xla_cmp_string_pkg.g_null_varchar2s;
--
-- Generate the definition to the ADR function
--
l_Adr := generate_adr_function (
         p_application_id             => p_application_id
       , p_amb_context_code           => p_amb_context_code
       , p_segment_rule_code          => p_segment_rule_code
       , p_segment_rule_type_code     => p_segment_rule_type_code
       , p_flexfield_assign_mode      => p_flexfield_assign_mode
       , p_flexfield_segment_code     => p_flexfield_segment_code
       , p_flex_value_set_id          => p_flex_value_set_id
       , p_transaction_coa_id         => p_transaction_coa_id
       , p_accounting_coa_id          => p_accounting_coa_id
       , p_adr_name                   => p_adr_name
       , p_array_adr_source_index     => l_array_adr_source_index
       , p_rec_aad_objects            => p_rec_aad_objects
       , p_rec_sources                => p_rec_sources
       --
       , p_IsCompiled                 => p_IsCompiled
       );
--
l_Adr := xla_cmp_string_pkg.replace_token(l_Adr,'$package_name$',g_package_name);
--
-- create the PL/SQL DBMS_SQL.VARCHAR2S array
--
xla_cmp_string_pkg.CreateString(
                      p_package_text  => l_Adr
                     ,p_array_string  => l_array_adr
                     );
--
-- reset PL/SQL arrays
--
l_array_adr_source_index        := l_array_null_adr_source_idx;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_msg      => 'l_isCompiled = '||CASE WHEN p_IsCompiled
                                                 THEN 'TRUE'
                                                 ELSE 'FALSE' END
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of generate_one_adr_fct'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_array_adr;
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled := FALSE;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION);
        END IF;
        RETURN xla_cmp_string_pkg.g_null_varchar2s;
   WHEN OTHERS THEN
        p_IsCompiled := FALSE;
        xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_one_adr_fct');
END generate_one_adr_fct;

/*----------------------------------------------------------------+
|                                                                 |
|  Private function                                               |
|                                                                 |
|       generate_adr_fcts                                         |
|                                                                 |
|  Generates AcctDerRule_XX() functions from ADRs assigned to AAD |
|                                                                 |
+----------------------------------------------------------------*/

FUNCTION generate_adr_fcts(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   IN OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--
--
CURSOR adr_cur
IS
--
SELECT DISTINCT
        xsrb.application_id
      , xsrb.segment_rule_type_code
      , xsrb.segment_rule_code
      , xsrb.flexfield_assign_mode_code
      , xsrb.flexfield_segment_code
      , xsrb.flex_value_set_id
      , xsrb.transaction_coa_id
      , xsrb.accounting_coa_id
      , REPLACE(xsrt.name , '''','''''')
  FROM  xla_aad_line_defn_assgns     xald
      , xla_line_defn_adr_assgns     xlda
      , xla_seg_rules_b              xsrb
      , xla_seg_rules_tl             xsrt
      , xla_prod_acct_headers        xpah
      , xla_line_definitions_b       xld
 WHERE xpah.application_id             = p_application_id
   AND xpah.amb_context_code           = p_amb_context_code
   AND xpah.product_rule_type_code     = p_product_rule_type_code
   AND xpah.product_rule_code          = p_product_rule_code
   AND xpah.accounting_required_flag   = 'Y'
   AND xpah.validation_status_code     = 'R'
   --
   AND xpah.application_id             = xald.application_id
   AND xpah.amb_context_code           = xald.amb_context_code
   AND xpah.event_class_code           = xald.event_class_code
   AND xpah.event_type_code            = xald.event_type_code
   AND xpah.product_rule_type_code     = xald.product_rule_type_code
   AND xpah.product_rule_code          = xald.product_rule_code
   --
   AND xald.application_id             = xlda.application_id
   AND xald.amb_context_code           = xlda.amb_context_code
   AND xald.event_class_code           = xlda.event_class_code
   AND xald.event_type_code            = xlda.event_type_code
   AND xald.line_definition_owner_code = xlda.line_definition_owner_code
   AND xald.line_definition_code       = xlda.line_definition_code
   --
   AND NVL(xlda.segment_rule_appl_id
          ,xlda.application_id)        = xsrb.application_id
   AND xlda.amb_context_code           = xsrb.amb_context_code
   AND xlda.segment_rule_code          = xsrb.segment_rule_code
   AND xlda.segment_rule_type_code     = xsrb.segment_rule_type_code
   AND xsrb.enabled_flag               = 'Y'
   --
   AND xsrb.application_id             = xsrt.application_id (+)
   AND xsrb.amb_context_code           = xsrt.amb_context_code (+)
   AND xsrb.segment_rule_code          = xsrt.segment_rule_code (+)
   AND xsrb.segment_rule_type_code     = xsrt.segment_rule_type_code (+)
   AND xsrt.language     (+)           = USERENV('LANG')
   --
   AND xald.application_id         = xld.application_id
   AND xald.amb_context_code       = xld.amb_context_code
   AND xald.event_class_code       = xld.event_class_code
   AND xald.event_type_code        = xld.event_type_code
   AND xald.line_definition_owner_code = xld.line_definition_owner_code
   AND xald.line_definition_code  = xld.line_definition_code
   AND xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
--ORDER BY xsrb.flexfield_segment_code, xsrb.segment_rule_type_code, xsrb.segment_rule_code
--------------------------
-- 4262811
--------------------------
UNION
SELECT  xsrb.application_id
      , xsrb.segment_rule_type_code
      , xsrb.segment_rule_code
      , xsrb.flexfield_assign_mode_code
      , xsrb.flexfield_segment_code
      , xsrb.flex_value_set_id
      , xsrb.transaction_coa_id
      , xsrb.accounting_coa_id
      , REPLACE(xsrt.name , '''','''''')
  FROM  xla_prod_acct_headers        xpah
      , xla_aad_line_defn_assgns     xald
      , xla_mpa_jlt_adr_assgns       xmja
      , xla_seg_rules_b              xsrb
      , xla_seg_rules_tl             xsrt
      , xla_line_definitions_b       xld
 WHERE xpah.application_id             = p_application_id
   AND xpah.amb_context_code           = p_amb_context_code
   AND xpah.product_rule_type_code     = p_product_rule_type_code
   AND xpah.product_rule_code          = p_product_rule_code
   AND xpah.accounting_required_flag   = 'Y'
   AND xpah.validation_status_code     = 'R'
   --
   AND xpah.application_id             = xald.application_id
   AND xpah.amb_context_code           = xald.amb_context_code
   AND xpah.event_class_code           = xald.event_class_code
   AND xpah.event_type_code            = xald.event_type_code
   AND xpah.product_rule_type_code     = xald.product_rule_type_code
   AND xpah.product_rule_code          = xald.product_rule_code
   --
   AND xald.application_id             = xmja.application_id
   AND xald.amb_context_code           = xmja.amb_context_code
   AND xald.event_class_code           = xmja.event_class_code
   AND xald.event_type_code            = xmja.event_type_code
   AND xald.line_definition_owner_code = xmja.line_definition_owner_code
   AND xald.line_definition_code       = xmja.line_definition_code
   --
   AND xmja.application_id             = xsrb.application_id
   AND xmja.amb_context_code           = xsrb.amb_context_code
   AND xmja.segment_rule_code          = xsrb.segment_rule_code
   AND xmja.segment_rule_type_code     = xsrb.segment_rule_type_code
   AND xmja.flexfield_segment_code     = nvl(xsrb.flexfield_segment_code,'ALL')
   AND xsrb.enabled_flag               = 'Y'
   --
   AND xsrb.application_id             = xsrt.application_id (+)
   AND xsrb.amb_context_code           = xsrt.amb_context_code (+)
   AND xsrb.segment_rule_code          = xsrt.segment_rule_code (+)
   AND xsrb.segment_rule_type_code     = xsrt.segment_rule_type_code (+)
   AND xsrt.language     (+)           = USERENV('LANG')
   --
   AND xald.application_id         = xld.application_id
   AND xald.amb_context_code       = xld.amb_context_code
   AND xald.event_class_code       = xld.event_class_code
   AND xald.event_type_code        = xld.event_type_code
   AND xald.line_definition_owner_code = xld.line_definition_owner_code
   AND xald.line_definition_code  = xld.line_definition_code
   AND xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
ORDER BY 5,2,3   --ORDER BY xsrb.flexfield_segment_code, xsrb.segment_rule_type_code, xsrb.segment_rule_code
;
--
l_array_adr_appl_id            xla_cmp_source_pkg.t_array_Num;
l_array_adr_code               xla_cmp_source_pkg.t_array_VL30;
l_array_adr_name               xla_cmp_source_pkg.t_array_VL80;
l_array_adr_type_code          xla_cmp_source_pkg.t_array_VL1;
l_array_assign_mode            xla_cmp_source_pkg.t_array_VL1;
l_array_flex_segment_code      xla_cmp_source_pkg.t_array_VL30;
l_array_flex_value_set_id      xla_cmp_source_pkg.t_array_Num;
l_array_trans_coa_id           xla_cmp_source_pkg.t_array_Num;
l_array_acctg_coa_id           xla_cmp_source_pkg.t_array_Num;
--
l_null_array_string            DBMS_SQL.VARCHAR2S;
l_array_string                 DBMS_SQL.VARCHAR2S;
l_Adrs                         DBMS_SQL.VARCHAR2S;
--
l_IsCompiled                   BOOLEAN;
l_log_module                   VARCHAR2(240);
--
BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_fcts';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_adr_fcts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code ||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code ||
                        ' - p_application_id = '||p_application_id ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

-- Init global variables
l_IsCompiled := TRUE;
--
OPEN  adr_cur;
--
FETCH adr_cur BULK COLLECT INTO   l_array_adr_appl_id
                                , l_array_adr_type_code
                                , l_array_adr_code
                                , l_array_assign_mode
                                , l_array_flex_segment_code
                                , l_array_flex_value_set_id
                                , l_array_trans_coa_id
                                , l_array_acctg_coa_id
                                , l_array_adr_name
                                 ;
CLOSE adr_cur;
--
l_Adrs   := l_null_array_string;
--
IF l_array_adr_code.COUNT > 0 THEN
   --
   FOR Idx In l_array_adr_code.FIRST .. l_array_adr_code.LAST LOOP
     --
        IF l_array_adr_code.EXISTS(Idx) THEN
        --
           l_array_string :=  generate_one_adr_fct(
                      p_application_id            =>  l_array_adr_appl_id(Idx)
                    , p_amb_context_code          =>  p_amb_context_code
                    , p_segment_rule_code         =>  l_array_adr_code(Idx)
                    , p_segment_rule_type_code    =>  l_array_adr_type_code(Idx)
                    , p_flexfield_assign_mode     =>  l_array_assign_mode(Idx)
                    , p_flexfield_segment_code    =>  l_array_flex_segment_code(Idx)
                    , p_flex_value_set_id         =>  l_array_flex_value_set_id(Idx)
                    , p_transaction_coa_id        =>  l_array_trans_coa_id(Idx)
                    , p_accounting_coa_id         =>  l_array_acctg_coa_id(Idx)
                    , p_adr_name                  =>  l_array_adr_name(Idx)
                    --
                    , p_rec_aad_objects           =>  p_rec_aad_objects
                    , p_rec_sources               =>  p_rec_sources
                    --
                    , p_IsCompiled                =>  l_IsCompiled
                   );
           --
           --
           l_Adrs := xla_cmp_string_pkg.ConcatTwoStrings (
                   p_array_string_1    => l_Adrs
                  ,p_array_string_2    => l_array_string
                   );
        --
        p_IsCompiled := p_IsCompiled AND l_IsCompiled;
        --
        END IF;
        --

END LOOP;
   --
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_adr_fcts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_Adrs;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION);
        END IF;
        p_IsCompiled := FALSE;
        RETURN l_null_array_string;
   WHEN OTHERS THEN
      IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.GenerateADR');
END generate_adr_fcts;

/*----------------------------------------------------------------+
|                                                                 |
|  Public function                                                |
|                                                                 |
|       generate_adr_fcts                                         |
|                                                                 |
|  Generates the AcctDerRule_XX() functions from ADRs assigned    |
|  to AAD.It returns TRUE if the generation succeed, otherwise    |
|  FALSE                                                          |
|                                                                 |
+----------------------------------------------------------------*/

FUNCTION GenerateADR(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_package_name                 IN VARCHAR2
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
IS
l_Adrs           DBMS_SQL.VARCHAR2S;
l_IsCompiled     BOOLEAN;
l_log_module     VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateADR';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateADR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code ||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code ||
                        ' - p_application_id = '||p_application_id ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

--
-- Init global variables
--

l_IsCompiled   := TRUE;
g_package_name := p_package_name;
l_Adrs         := xla_cmp_string_pkg.g_null_varchar2s;
--

l_Adrs := generate_adr_fcts(
   p_product_rule_code         =>  p_product_rule_code
 , p_product_rule_type_code    =>  p_product_rule_type_code
 , p_application_id            =>  p_application_id
 , p_amb_context_code          =>  p_amb_context_code
  --
 , p_rec_aad_objects           =>  p_rec_aad_objects
 , p_rec_sources               =>  p_rec_sources
 --
 , p_IsCompiled                =>  l_IsCompiled
);
--
--
p_package_body := l_Adrs;
g_package_name := NULL;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
      (p_msg      => 'l_isCompiled = '||CASE WHEN l_IsCompiled
                                                THEN 'TRUE'
                                                ELSE 'FALSE' END
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);

   trace
      (p_msg      => 'END of GenerateADR'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_IsCompiled;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_adr_pkg.GenerateADR');
END GenerateADR;


--Added for the Transaction Account Builder

/*------------------------------------------------------------+
|                                                             |
|                                                             |
|            Transaction Account Builder compiler             |
|                                                             |
|                                                             |
|                                                             |
+------------------------------------------------------------*/

/*------------------------------------------------------------+
|                                                             |
|  Private Function                                           |
|                                                             |
|       generate_adr_spec                                     |
|                                                             |
|                                                             |
+------------------------------------------------------------*/

FUNCTION generate_adr_spec(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_segment_rule_code            IN VARCHAR2
, p_segment_rule_type_code       IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_flexfield_segment_code       IN VARCHAR2
, p_transaction_coa_id           IN NUMBER
, p_accounting_coa_id            IN NUMBER
, p_adr_name                     IN VARCHAR2

, p_array_adr_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt

, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources

, x_adr_spec_text                OUT    NOCOPY CLOB
)
RETURN BOOLEAN
IS

l_Adr                      CLOB;
l_parms                    VARCHAR2(10000);
l_code                     VARCHAR2(30);
l_ObjectIndex              BINARY_INTEGER;

l_fatal_error_message_text VARCHAR2(240);
l_log_module               VARCHAR2 (2000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_adr_spec';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN of generate_adr_spec'
         ,p_level    => C_LEVEL_PROCEDURE);

   END IF;

   --Select the correct template
   IF   g_component_type  = 'AMB_ADR'
   THEN
      x_adr_spec_text      := NULL;
   ELSIF g_component_type  = 'TAB_ADR'
   THEN
      --CCID rule
      IF p_flexfield_assign_mode = 'A'
      THEN
         x_adr_spec_text      := C_ADR_CCID_TAD_FUNCT_SPEC;
      --Segment rule
      ELSIF p_flexfield_assign_mode = 'S'
      THEN
         x_adr_spec_text      := C_ADR_SEGMENT_TAD_FUNCT_SPEC;
      ELSE
         l_fatal_error_message_text := 'Invalid p_flexfield_assign_mode: ' ||
                                       p_flexfield_assign_mode;
         RAISE ge_fatal_error;
      END IF;
   ELSE
      l_fatal_error_message_text := 'Invalid g_component_type: ' ||
                                    g_component_type;
      RAISE ge_fatal_error;
   END IF;

   l_parms:= xla_cmp_source_pkg.get_obj_parm_for_tab(
              p_array_source_index   => p_array_adr_source_index
            , p_rec_sources          => p_rec_sources
            );

    x_adr_spec_text     := xla_cmp_string_pkg.replace_token( x_adr_spec_text
                                   ,'$parameters$'
                                   ,NVL(l_parms, ' ')
                                  );  -- 4417664

   l_ObjectIndex := xla_cmp_source_pkg.CacheAADObject (
               p_object                    => xla_cmp_source_pkg.C_ADR
             , p_object_code               => p_segment_rule_code
             , p_object_type_code          => p_segment_rule_type_code
             , p_application_id            => p_application_id
             , p_array_source_Index        => p_array_adr_source_index
             , p_rec_aad_objects           => p_rec_aad_objects
             );

   l_code               := TO_CHAR(l_ObjectIndex);
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$adr_hash_id$'
                                ,l_code);
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$account_derivation_rule_code$'
                                ,p_segment_rule_code);
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$adr_type_code$'
                                ,p_segment_rule_type_code);
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$adr_appl_id$'
                                ,to_char(p_application_id) );
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$amb_context_code$'
                                ,p_amb_context_code);
   x_adr_spec_text      := xla_cmp_string_pkg.replace_token( x_adr_spec_text  -- 4417664
                                ,'$flexfield_segment_code$'
                                ,p_flexfield_segment_code);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'END of generate_adr_spec'
         ,p_level    => C_LEVEL_PROCEDURE);

   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN ge_fatal_error
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module => l_log_module
            ,p_msg      => l_fatal_error_message_text
            ,p_level    => C_LEVEL_EXCEPTION);

      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.generate_adr_spec'
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;

   WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION);
        END IF;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN FALSE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_adr_spec');
END generate_adr_spec;


/*------------------------------------------------------------+
|                                                             |
|  Private Function                                           |
|                                                             |
|       generate_tab_adr                                      |
|                                                             |
|                                                             |
+------------------------------------------------------------*/

FUNCTION generate_tab_adr(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_segment_rule_code            IN VARCHAR2
, p_segment_rule_type_code       IN VARCHAR2
, p_flexfield_assign_mode        IN VARCHAR2
, p_flexfield_segment_code       IN VARCHAR2
, p_flex_value_set_id            IN NUMBER
, p_transaction_coa_id           IN NUMBER
, p_accounting_coa_id            IN NUMBER
, p_adr_name                     IN VARCHAR2
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, x_adr_hash_id                  OUT    NOCOPY BINARY_INTEGER
, x_adr_function_name            OUT    NOCOPY VARCHAR2
, x_table_of_adr_sources         OUT    NOCOPY gt_table_of_adr_sources
, x_adr_spec                     OUT    NOCOPY CLOB
, x_adr_body                     OUT    NOCOPY CLOB

)
RETURN  BOOLEAN
IS

l_array_adr_source_index         xla_cmp_source_pkg.t_array_ByInt;
l_array_null_adr_source_Idx      xla_cmp_source_pkg.t_array_ByInt;

l_adr_code                 VARCHAR2(30);
l_adr_body                 VARCHAR2(32000);
l_parms                    VARCHAR2(10000);
l_array_adr                DBMS_SQL.VARCHAR2S;
l_IsCompiled               BOOLEAN;

l_fatal_error_message_text VARCHAR2(240);
l_adr_function_name        VARCHAR2(30);
l_log_module               VARCHAR2 (2000);

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_tab_adr';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN of generate_tab_adr'
         ,p_level    => C_LEVEL_PROCEDURE);

END IF;

--
-- init global variables
--
g_component_code      := p_segment_rule_code;
g_component_type_code := p_segment_rule_type_code;
g_component_appl_id   := p_application_id;
g_component_name      := p_adr_name;
g_amb_context_code    := p_amb_context_code;
--

l_array_adr           := xla_cmp_string_pkg.g_null_varchar2s;
--
-- Generate the body of the ADR function
--
x_adr_body := generate_adr_function (
         p_application_id             => p_application_id
       , p_amb_context_code           => p_amb_context_code
       , p_segment_rule_code          => p_segment_rule_code
       , p_segment_rule_type_code     => p_segment_rule_type_code
       , p_flexfield_assign_mode      => p_flexfield_assign_mode
       , p_flexfield_segment_code     => p_flexfield_segment_code
       , p_flex_value_set_id          => p_flex_value_set_id
       , p_transaction_coa_id         => p_transaction_coa_id
       , p_accounting_coa_id          => p_accounting_coa_id
       , p_adr_name                   => p_adr_name
       --
       , p_array_adr_source_index     => l_array_adr_source_index
       --
       , p_rec_aad_objects            => p_rec_aad_objects
       , p_rec_sources                => p_rec_sources
       --
       , p_IsCompiled                 => l_IsCompiled
       );

-- Generate the specification of the ADR function
l_IsCompiled := l_IsCompiled AND generate_adr_spec (
         p_application_id             => p_application_id
       , p_amb_context_code           => p_amb_context_code
       , p_segment_rule_code          => p_segment_rule_code
       , p_segment_rule_type_code     => p_segment_rule_type_code
       , p_flexfield_assign_mode      => p_flexfield_assign_mode
       , p_flexfield_segment_code     => p_flexfield_segment_code
       , p_transaction_coa_id         => p_transaction_coa_id
       , p_accounting_coa_id          => p_accounting_coa_id
       , p_adr_name                   => p_adr_name
       --
       , p_array_adr_source_index     => l_array_adr_source_index
       --
       , p_rec_aad_objects            => p_rec_aad_objects
       , p_rec_sources                => p_rec_sources
       --
       , x_adr_spec_text              => x_adr_spec
       );

--Get the ADR hash id assigned during the compilation
x_adr_hash_id := xla_cmp_source_pkg.CacheAADObject
                  (
                    p_object                    => xla_cmp_source_pkg.C_ADR
                   ,p_object_code               => p_segment_rule_code
                   ,p_object_type_code          => p_segment_rule_type_code
                   ,p_application_id            => p_application_id
                   ,p_array_source_Index        => l_array_adr_source_index
                   ,p_rec_aad_objects           => p_rec_aad_objects
                  );

--Get the ADR function name
IF p_flexfield_assign_mode = 'A' THEN
   l_adr_function_name := C_ADR_CCID_TAD_FUNCT_NAME;
ELSIF p_flexfield_assign_mode = 'S' THEN
   l_adr_function_name := C_ADR_SEGMENT_TAD_FUNCT_NAME;
ELSE
   l_fatal_error_message_text := 'Unrecognized p_flexfield_assign_mode: '
                                 || p_flexfield_assign_mode;
END IF;

l_adr_function_name := REPLACE( l_adr_function_name
                               ,'$adr_hash_id$'
                               ,x_adr_hash_id
                              );

x_adr_function_name         := l_adr_function_name;

--Get the list of the sources referenced in the ADR
--x_table_of_adr_sources := gt_table_of_adr_sources();
IF l_array_adr_source_index.COUNT > 0   THEN
   FOR Idx IN l_array_adr_source_index.FIRST .. l_array_adr_source_index.LAST
   LOOP
      IF l_array_adr_source_index.EXISTS(Idx)
      THEN
         x_table_of_adr_sources(l_array_adr_source_index(Idx)):= p_rec_sources.array_source_code(Idx);
      END IF;
   END LOOP;
END IF;


--
-- reset PL/SQL arrays
--
l_array_adr_source_index        := l_array_null_adr_source_idx;
--

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'END of generate_tab_adr'
         ,p_level    => C_LEVEL_PROCEDURE);

   END IF;


RETURN TRUE;
--
EXCEPTION
   WHEN ge_fatal_error
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => l_fatal_error_message_text
            ,p_level    => C_LEVEL_EXCEPTION);

      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.generate_tab_adr'
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      RETURN FALSE;
   WHEN xla_exceptions_pkg.application_exception   THEN
      RETURN FALSE;
   WHEN OTHERS THEN
        xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.generate_tab_adr');
END generate_tab_adr;

/*------------------------------------------------------------+
|                                                             |
|  Public TAB Function                                        |
|                                                             |
|       build_adrs_for_tab                                    |
|                                                             |
|                                                             |
+------------------------------------------------------------*/

FUNCTION build_adrs_for_tab
   (
     p_table_of_adrs_in     IN    gt_table_of_adrs_in
    ,x_table_of_adrs_out    OUT   NOCOPY gt_table_of_adrs_out
    ,x_adr_specs_text       OUT   NOCOPY CLOB
    ,x_adr_bodies_text      OUT   NOCOPY CLOB
  )
RETURN BOOLEAN
IS

CURSOR adr_cur ( cp_application_id               NUMBER
                ,cp_segment_rule_code            VARCHAR2
                ,cp_segment_rule_type_code       VARCHAR2
                ,cp_amb_context_code             VARCHAR2
                )
IS

SELECT xsrb.application_id
      ,xsrb.segment_rule_code
      ,xsrb.segment_rule_type_code
      ,xsrb.amb_context_code
      ,xsrb.flexfield_assign_mode_code
      ,xsrb.flexfield_segment_code
      ,xsrb.flex_value_set_id
      ,xsrb.transaction_coa_id
      ,xsrb.accounting_coa_id
      ,REPLACE(xsrt.name , '''','''''')
  FROM  xla_seg_rules_b        xsrb
      , xla_seg_rules_tl       xsrt
 WHERE xsrb.application_id             = cp_application_id
   AND xsrb.segment_rule_code          = cp_segment_rule_code
   AND xsrb.segment_rule_type_code     = cp_segment_rule_type_code
   AND xsrb.amb_context_code           = cp_amb_context_code
   AND xsrb.enabled_flag               = 'Y'
   AND xsrt.application_id         (+) =  xsrb.application_id
   AND xsrt.amb_context_code       (+) =  xsrb.amb_context_code
   AND xsrt.segment_rule_code      (+) =  xsrb.segment_rule_code
   AND xsrt.segment_rule_type_code (+) =  xsrb.segment_rule_type_code
   AND xsrt.language               (+) =  USERENV('LANG')
;


l_application_id               NUMBER;
l_segment_rule_code            VARCHAR2(30);
l_segment_rule_type_code       VARCHAR2(1);
l_flex_value_set_id            NUMBER;
l_amb_context_code             VARCHAR2(30);
l_flex_assign_mode_code        VARCHAR2(1);
l_flex_segment_code            VARCHAR2(30);
l_trans_coa_id                 NUMBER;
l_acctg_coa_id                 NUMBER;
l_adr_name                     VARCHAR2(80);

l_rec_aad_objects              xla_cmp_source_pkg.t_rec_aad_objects ;
l_rec_sources                  xla_cmp_source_pkg.t_rec_sources;


l_array_string                 DBMS_SQL.VARCHAR2S;

l_adr_spec                     CLOB;
l_adr_body                     CLOB;

l_adr_hash_id                  BINARY_INTEGER;
l_adr_function_name            VARCHAR2(30);
l_table_of_adr_sources         gt_table_of_adr_sources;

l_compiled                     BOOLEAN;
l_all_compiled                 BOOLEAN;

l_fatal_error_message_text     VARCHAR2(240);
l_log_module                 VARCHAR2 (2000);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_adrs_for_tab';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN of build_adrs_for_tab'
         ,p_level    => C_LEVEL_PROCEDURE);

   END IF;

   --Initialize the global variable that indicates the component type
   --The default is AMB_ADR but ADRs generated for the Transaction Account Builder
   --need some special processing.
   g_component_type :='TAB_ADR';

   l_compiled     := TRUE;
   l_all_compiled := TRUE;

   IF p_table_of_adrs_in.FIRST IS NOT NULL THEN
      FOR Idx In p_table_of_adrs_in.FIRST..p_table_of_adrs_in.LAST LOOP
         IF p_table_of_adrs_in.EXISTS(Idx) THEN

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
               (p_module   => l_log_module
               ,p_msg      => 'Current rule'
               ,p_level    => C_LEVEL_STATEMENT);
               trace
               (p_module   => l_log_module
               ,p_msg      => 'application_id: ' ||
                              p_table_of_adrs_in(Idx).application_id
               ,p_level    => C_LEVEL_STATEMENT);
               trace
               (p_module   => l_log_module
               ,p_msg      => 'segment_rule_code: ' ||
                              p_table_of_adrs_in(Idx).segment_rule_code
               ,p_level    => C_LEVEL_STATEMENT);
               trace
               (p_module   => l_log_module
               ,p_msg      => 'segment_rule_type_code: ' ||
                              p_table_of_adrs_in(Idx).segment_rule_type_code
               ,p_level    => C_LEVEL_STATEMENT);
               trace
               (p_module   => l_log_module
               ,p_msg      => 'amb_context_code: ' ||
                              p_table_of_adrs_in(Idx).amb_context_code
               ,p_level    => C_LEVEL_STATEMENT);
            END IF;

            --Fetch additional details for the ADR
            OPEN  adr_cur
               (
      cp_application_id         => p_table_of_adrs_in(Idx).application_id
     ,cp_segment_rule_code      => p_table_of_adrs_in(Idx).segment_rule_code
     ,cp_segment_rule_type_code => p_table_of_adrs_in(Idx).segment_rule_type_code
     ,cp_amb_context_code       => p_table_of_adrs_in(Idx).amb_context_code
               );

            FETCH adr_cur
             INTO l_application_id
                 ,l_segment_rule_code
                 ,l_segment_rule_type_code
                 ,l_amb_context_code
                 ,l_flex_assign_mode_code
                 ,l_flex_segment_code
                 ,l_flex_value_set_id
                 ,l_trans_coa_id
                 ,l_acctg_coa_id
                 ,l_adr_name;
            IF adr_cur%ROWCOUNT <> 1
            THEN
               CLOSE adr_cur;
               l_fatal_error_message_text := 'Unable to retrieve ADR info: ';
               RAISE ge_fatal_error;
            END IF;

            CLOSE adr_cur;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
               (p_module   => l_log_module
               ,p_msg      => 'Fetched segment_rule_code: ' ||
                              l_segment_rule_code
               ,p_level    => C_LEVEL_STATEMENT);
            END IF;

            l_compiled :=  generate_tab_adr(
                    p_application_id            => l_application_id
                   ,p_segment_rule_code         => l_segment_rule_code
                   ,p_segment_rule_type_code    => l_segment_rule_type_code
                   ,p_amb_context_code          => l_amb_context_code
                   ,p_flexfield_assign_mode     => l_flex_assign_mode_code
                   ,p_flexfield_segment_code    => l_flex_segment_code
                   ,p_flex_value_set_id         => l_flex_value_set_id
                   ,p_transaction_coa_id        => l_trans_coa_id
                   ,p_accounting_coa_id         => l_acctg_coa_id
                   ,p_adr_name                  => l_adr_name

                   ,p_rec_aad_objects           => l_rec_aad_objects
                   ,p_rec_sources               => l_rec_sources

                   ,x_adr_hash_id               => l_adr_hash_id
                   ,x_adr_function_name         => l_adr_function_name
                   ,x_table_of_adr_sources      => l_table_of_adr_sources
                   ,x_adr_spec                  => l_adr_spec
                   ,x_adr_body                  => l_adr_body
                   );

            IF l_compiled
            THEN
               --Retrieve the function name assigned to the ADR
               x_table_of_adrs_out(Idx).adr_function_name
                  := l_adr_function_name;
               --Retrieve the hash id assigned to the ADR
               x_table_of_adrs_out(Idx).adr_hash_id
                  := l_adr_hash_id;
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                  (p_module   => l_log_module
                  ,p_msg      => 'l_adr_hash_id: ' ||
                                 l_adr_hash_id
                  ,p_level    => C_LEVEL_STATEMENT);
               END IF;


               x_table_of_adrs_out(Idx).table_of_sources
                  := l_table_of_adr_sources;

               x_adr_specs_text   := x_adr_specs_text   ||
                                    l_adr_spec;

               x_adr_bodies_text := x_adr_bodies_text ||
                                    l_adr_body;

            END IF;

            l_all_compiled := l_all_compiled AND l_compiled;

         END IF;

      END LOOP;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_module => l_log_module
         ,p_msg      => 'END of build_adrs_for_tab ('
                        || xla_cmp_common_pkg.bool_to_char
                             (
                                p_boolean => l_all_compiled
                             )
                        || ')'
         ,p_level    => C_LEVEL_PROCEDURE);

   END IF;

   RETURN l_all_compiled;

EXCEPTION
   WHEN ge_fatal_error
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_module   => l_log_module
            ,p_msg      => l_fatal_error_message_text
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || C_DEFAULT_MODULE||'.build_adrs_for_tab'
         ,p_level    => C_LEVEL_PROCEDURE);
      END IF;
      l_all_compiled := FALSE;
      RETURN l_all_compiled;

   WHEN xla_exceptions_pkg.application_exception   THEN
        IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
        l_all_compiled := FALSE;
        RETURN l_all_compiled;
   WHEN OTHERS THEN
      IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
      l_all_compiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_adr_pkg.build_adrs_for_tab');

END build_adrs_for_tab
;
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
END xla_cmp_adr_pkg; --

/
