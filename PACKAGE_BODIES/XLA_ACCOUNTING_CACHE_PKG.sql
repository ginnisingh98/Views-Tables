--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_CACHE_PKG" AS
-- $Header: xlaapche.pkb 120.54.12010000.2 2009/03/02 14:07:16 karamakr ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaapche.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_accounting_cache_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|    This package is defined to cache the frequently used data during        |
|    execution of Accounting Program. This is to improve performance and     |
|    provide modular structure and lean interaction between Accounting Engine|
|    and Accounting Program.                                                 |
|                                                                            |
|    Note: the APIs do not excute COMMIT or ROLLBACK.                        |
|                                                                            |
| HISTORY                                                                    |
|    30-Oct-02  S. Singhania    Created                                      |
|    06-Dec-02  S. Singhania    Made changes to reslove bug # 2695671.       |
|                                 Added NVL statement to default ledger's    |
|                                 description language to USERENV('LANG')    |
|    11-Dec-02  K. Boussema     Updated function GetBaseLedgerId             |
|    19-Dec-02  S. Singhania    Fixed the bug # 2701293. Added new sources to|
|                                 the cache. Added set_process_cache.        |
|    06-Jan-03  S. Singhania    Made changes due to change in column names of|
|                                 ledger view XLA_ALT_CURR_LEDGERS_V         |
|    08-Jan-03  K. Boussema     Update GetTranslatedValueChar to get         |
|                                 XLA_NLS_DESC_LANGUAGE and                  |
|                                 XLA_ACCT_REVERSAL_OPTION values            |
|    16-Jan-03  S. Singhania    Made changes due to changes in the ledger    |
|                                 view XLA_ALT_CURR_LEDGERS_V                |
|    21-Feb-03  S. Singhania    Made changes for the new bulk approach of the|
|                                 accounting program                         |
|                                      - added 'p_max_event_date' param to   |
|                                           load_application_ledgers         |
|                                      - added procedure 'get_pad_info'      |
|                                      - removed datatypes to cache event    |
|                                           information                      |
|                                      - merged ledger cahce structures      |
|                                      - formatting.                         |
|    04-Apr-03  S. Singhania    rewrote the APIs and Modified the specs for: |
|                                 - GetValueNum                              |
|                                 - GetValueDate                             |
|                                 - GetValueChar                             |
|                               Made changes due to amb_context_code and new |
|                                 sources. Please refer to bug # 2887554     |
|    02-May-03  S. Singhania    Added section to initilize variables under   |
|                                 LOAD_APPLICATION_LEDGERS                   |
|                               Added 'allow_intercompany_post_flag' to the  |
|                                 cache (bug # 2922615)                      |
|    03-May-03  S. Singhania    Added more exception handlers for debugging  |
|    07-May-03  S. Singhania    Based on requirements from the 'Accounting   |
|                                 Engine' remodified the specifications for: |
|                                 - GetValueNum                              |
|                                 - GetValueDate                             |
|                                 - GetValueChar                             |
|                                 - load_application_ledgers                 |
|                                 - GetAlcLedgers                            |
|                               Modified code to support new specifications  |
|                               Renamed 'GetBaseLedgers' to 'GetLedgers'     |
|                               Modified the structure of cache to handle ALC|
|                                 as there will not be any ALC for secondary |
|                               Added local 'Trace' package                  |
|    08-May-03  S. Singhania    Modified ALC cache structure and alc cursor  |
|                                 to include SLA_LEDGER_ID as attribute of   |
|                                 ALC ledgers.(bug # 2948635)                |
|    12-Jun-03  S. Singhania    Added trace messages in GET_PAD_INFO         |
|                               Added correct calls to FND Messages (bug #   |
|                                 3001156)                                   |
|    25-Jun-03  S. Singhania    Modified the package to use FND_LOG.         |
|    16-Jul-03  S. Singhania    Added following APIs:                        |
|                                 - GetValueNum         (Overloaded)         |
|                                 - GetValueDate        (Overloaded)         |
|                                 - GetValueChar        (Overloaded)         |
|                                 - GetSessionValueChar                      |
|                                 - GetSessionValueChar (Overloaded)         |
|                                 - get_event_info                           |
|                               Added following internal routines            |
|                                 - load_system_sources                      |
|                                 - is_source_valid                          |
|                               Modified specifications for:                 |
|                                 - GetValueChar                             |
|                                 - Get_PAD_info                             |
|                               Modified the cache structures.               |
|    21-Jul-03  S. Singhania    Added NVL in GET_PAD_INFO for date comparison|
|                               modified the where clause for csr_ledger_pad |
|                                 to select all pads before event's max date |
|                                 (bug # 3036628)                            |
|    25-Jul-03  S. Singhania    Modified LOAD_APPLICATION_LEDGERS to reduce  |
|                                 code maintenance.                          |
|    01-Aug-03  S. Singhania    Enabled the validation in IS_SOURCE_VALID to |
|                                 make sure the system source code is defined|
|                                 in AMB.                                    |
|    11-Sep-03  S. Singhania    Made changes to cache je_category (# 3109690)|
|                                 - Modified the structures that store 'event|
|                                   class' and 'event type' info.            |
|                                 - Modified CACHE_APPLICATION_SETUP to cache|
|                                   je_categories for event_class/ledger.    |
|                                 - Added API GET_JE_CATEGORY                |
|    21-Nov-03  S. Singhania    Added new system source (bug # 3264446)      |
|                                   DYNAMIC_INSERTS_ALLOWED_FLAG.            |
|    22-Dec-03  S. Singhania    Made changes for the FND_LOG.                |
|                               Added the condition in cursor csr_base_ledger|
|                                 in LOAD_APPLICATION_LEDGERS to check if    |
|                                 relationship is enabled in configurations. |
|    06-Jan-04  S. Singhania    Further FND_LOG changes.                     |
|    16-Feb-04  S. Singhania    Bug 3443779. Cached ledger_category_code for |
|                                 ALC ledgers.                               |
|    18-Mar-04  S. Singhania    Added a parameter p_module to the TRACE calls|
|                                 and the procedure.                         |
|    20-Sep-04  S. Singhania    Added the following to support bulk changes  |
|                                 in the accounting engine                   |
|                                 - Added API GetArrayPad                    |
|    01-NOV-04  S. Singhania    Made changes for Valuation Method            |
|                                 .Enhancements:                             |
|                                 - Modified LOAD_APPLICATION_LEDGERS        |
|                               Fixed GSCC warning File.Sql.35               |
|    9-Mar-05   W. Shen         Add the function BuildLedgerArray and        |
|                                 GetLedgerArray to support the calculation  |
|                                 of rounding                                |
|                               Add several field to the cache too           |
|                                 XLA_ALC_ENABLED_FLAG                       |
|                                 XLA_ROUNDING_CCID                          |
|                                 XLA_INHERIT_CONVERSION_TYPE                |
|                                 XLA_DEFAULT_CONV_RATE_TYPE                 |
|                                 XLA_MAX_DAYS_ROLL_RATE                     |
|                                 XLA_CURRENCY_MAU                           |
|                                 XLA_ROUNDING_RULE_CODE                     |
|    26-May-05   W. Shen         Add the function GetCurrencyMau             |
|    27-May-05   W. Chan         Fix bug 4161247 - Add following to cache:   |
|                                1. transaction_calendar_id                  |
|                                2. enable_average_balances_flag             |
|                                3. effective_date_rule_code                 |
|    20-Jun-05   W. Shen         Fix bug 4444191, add ledger name for alc    |
|    5-Jul-05    W. Shen         Fix bug 4476180, treat the flag             |
|                                'ALC_INHERIT_CONVERSION_TYPE' as 'Y' when   |
|                                it is null                                  |
|    17-Aug-05   V. Swapna       Fix bug 4554935, modified                   |
|                                  cursor csr_je_category                    |
|    01-Dec-05   S. Singhania    Bug 4640689. Modified cursors:              |
|                                 csr_base_ledger and csr_alc_ledger         |
|                                 to get right value for sla_ledger_id       |
|    24-Jan-06   V. Swapna       Fix bug 4736579. Added an exception         |
|                                 in get_je_category procedure.              |
|    02-Mar-06   V. Swapna       Bug 5018098: Added an exception in          |
|                                 load_application_ledgers procedure.        |
+===========================================================================*/

--=============================================================================
--           ****************  declarations  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring data types
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_char_value IS TABLE OF VARCHAR2(240) INDEX BY VARCHAR2(30);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_num_value IS TABLE OF NUMBER INDEX BY VARCHAR2(30);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_date_value IS TABLE OF DATE INDEX BY VARCHAR2(30);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_je_category IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_record_sources IS RECORD
   (char_sources                t_array_char_value
   ,num_sources                 t_array_num_value
   ,date_sources                t_array_date_value
   ,char_sources_sl             t_array_char_value);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_record_ledger IS RECORD
   (category_code               VARCHAR2(30)
   ,char_sources                t_array_char_value
   ,num_sources                 t_array_num_value
   ,date_sources                t_array_date_value
   ,char_sources_sl             t_array_char_value
   ,pads                        t_array_pad);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_ledger IS TABLE OF t_record_ledger INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_record_event_type IS RECORD
   (event_type_name_tl                       t_array_char_value
   ,event_type_name_sl                       VARCHAR2(240));

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_event_type IS TABLE of t_record_event_type INDEX BY VARCHAR2(30);

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_record_event_class IS RECORD
   (event_class_name_tl                    t_array_char_value
   ,xla_je_category                        t_array_je_category
   ,event_class_name_sl                    VARCHAR2(240));

TYPE t_record_currency_mau is RECORD
   ( currency_code                         VARCHAR2(30)
    ,currency_mau                          NUMBER);
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
TYPE t_array_event_class IS TABLE of t_record_event_class INDEX BY VARCHAR2(30);

-------------------------------------------------------------------------------
-- declaring package variables
-------------------------------------------------------------------------------
g_primary_ledger_id                 NUMBER;
g_record_session                    t_record_sources;
g_base_ledger_ids                   t_array_ledger_id;
g_alc_ledger_ids                    t_array_ledger_id;
g_array_ledger                      t_array_ledger;
g_array_sources                     t_array_char_value;
g_array_event_classes               t_array_event_class;
g_array_event_types                 t_array_event_type;
g_array_ledger_attrs                t_array_ledger_attrs;
g_entered_currency_mau              t_record_currency_mau;
g_entered_currency_mau1             t_record_currency_mau;
g_entered_currency_mau2             t_record_currency_mau;


-------------------------------------------------------------------------------
-- Forward declaration of local routines
-------------------------------------------------------------------------------
PROCEDURE cache_application_setup
       (p_application_id             IN  INTEGER
       ,p_ledger_id                  IN  INTEGER
       ,p_ledger_category            IN  VARCHAR2);

PROCEDURE load_system_sources;

FUNCTION is_source_valid
       (p_source_code         IN VARCHAR2
       ,p_datatype            IN VARCHAR2)
RETURN BOOLEAN;
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_cache_pkg';

--g_log_module          VARCHAR2(240);
g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
--l_module         VARCHAR2(240);
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_cache_pkg.trace');
END trace;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================

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
-- Following are public routines
--
--    1.    load_application_ledgers
--    2.    get_pad_info
--    3.    get_event_info
--    4.    GetValueNum
--    5.    GetValueNum           (Overloaded API)
--    6.    GetValueDate
--    7.    GetValueDate          (Overloaded API)
--    8.    GetValueChar
--    9.    GetValueChar          (overloaded API)
--   10.    GetSessionValueChar
--   11.    GetSessionValueChar   (overloaded API)
--   12.    GetAlcLedgers
--   13.    GetLedgers
--   14.    get_je_category
--   15.    GetArrayPad
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
--
--
--
--=============================================================================
PROCEDURE load_application_ledgers
       (p_application_id             IN  INTEGER
       ,p_event_ledger_id            IN  INTEGER
       ,p_max_event_date             IN  DATE) IS
CURSOR csr_base_ledger (x_event_ledger_category IN VARCHAR2) IS
   (SELECT fat.application_name                 application_name
          ,fat.application_id                   application_id
          ,gjs.user_je_source_name              user_je_source_name
          ,xso.je_source_name                   je_source_name
          ,xso.name                             ledger_name
          ,xso.ledger_id                        ledger_id
          ,fst.id_flex_structure_name           ledger_coa_name
          ,fsv.id_flex_structure_name           session_coa_name
          ,fsv.dynamic_inserts_allowed_flag     dynamic_inserts_allowed_flag
          ,xso.chart_of_accounts_id             coa_id
          ,amt.name                             ledger_slam_name
          ,amv.name                             session_slam_name
          ,xso.sla_accounting_method_code       slam_code
          ,xso.sla_accounting_method_type       slam_type
          ,xso.currency_code                    xla_currency_code
          ,NVL(xso.sla_description_language,SYS_CONTEXT('USERENV','LANG'))
                                                xla_description_language
          ,NVL(fla.nls_language,SYS_CONTEXT('USERENV','NLS_DATE_LANGUAGE'))
                                                xla_nls_desc_language
          ,xso.sla_entered_cur_bal_sus_ccid     xla_entered_cur_bal_sus_ccid
          ,xso.res_encumb_code_combination_id   res_encumb_code_combination_id
          ,xso.ledger_category_code             ledger_category_code
          ,fcu.precision                        ledger_currency_precision
          ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                                                ledger_currency_mau
          ,xso.rounding_rule_code               xla_rounding_rule_code
          ,xso.sl_coa_mapping_id                coa_mapping_id
          ,gcm.name                             coa_mapping_name
          ,xso.bal_seg_column_name              bal_seg_column_name
          ,xso.mgt_seg_column_name              mgt_seg_column_name
          ,xso.sla_bal_by_ledger_curr_flag      xla_ledger_cur_bal_flag
          ,xso.sla_ledger_cur_bal_sus_ccid      xla_ledger_cur_bal_sus_ccid
          ,xso.rounding_code_combination_id     xla_rounding_ccid
          ,xso.acct_reversal_option_code        xla_acct_reversal_option_code
          -- the following is modified for bug 4640689
          ,decode(xso.capture_event_flag
                 ,'Y',xso.ledger_id
                 ,xso.primary_ledger_id)        sla_ledger_id
          ,xso.latest_encumbrance_year          latest_encumbrance_year
          ,xso.bal_seg_value_option_code        bal_seg_value_option_code
          ,xso.mgt_seg_value_option_code        mgt_seg_value_option_code
          ,xso.allow_intercompany_post_flag     allow_intercompany_post_flag
          ,nvl(xso.ALC_INHERIT_CONVERSION_TYPE, 'Y') ALC_INHERIT_CONVERSION_TYPE
          ,xso.ALC_DEFAULT_CONV_RATE_TYPE
          ,decode(xso.ALC_NO_RATE_ACTION_CODE, 'FIND_RATE', nvl(xso.ALC_MAX_DAYS_ROLL_RATE, -1), 0)
                                                ALC_MAX_DAYS_ROLL_RATE
          ,xso.transaction_calendar_id      transaction_calendar_id
          ,xso.enable_average_balances_flag enable_average_balances_flag
          ,gjs.effective_date_rule_code     effective_date_rule_code
          ,xso.suspense_allowed_flag        suspense_allowed_flag
      FROM xla_subledger_options_v          xso
          ,fnd_application_tl               fat
          ,gl_je_sources_vl                 gjs
          ,fnd_id_flex_structures_tl        fst
          ,fnd_id_flex_structures_vl        fsv
          ,xla_acctg_methods_tl             amt
          ,xla_acctg_methods_vl             amv
          ,fnd_currencies                   fcu
          ,fnd_languages                    fla
          ,gl_coa_mappings                  gcm
     WHERE xso.application_id               = p_application_id
       AND xso.relationship_enabled_flag    = 'Y'
       AND xso.sla_accounting_method_code   IS NOT NULL
       --
       -- >> valuation method enhanacements
       --
       AND DECODE(x_event_ledger_category
                 ,'PRIMARY',xso.primary_ledger_id
                 ,xso.ledger_id)            = p_event_ledger_id
       AND DECODE(x_event_ledger_category
                 ,'PRIMARY',DECODE(xso.ledger_category_code
                                  ,'PRIMARY','Y'
                                  ,'N')
                 ,'Y')                      = xso.capture_event_flag
       --
       -- << valuation method enhanacements
       --
       AND xso.enabled_flag                 = 'Y'
       AND fat.application_id               = xso.application_id
       AND fat.language                     =
                         NVL(xso.sla_description_language,SYS_CONTEXT('USERENV','LANG'))
       AND gjs.je_source_name               = xso.je_source_name
       AND fst.application_id               = 101
       AND fst.id_flex_code                 = 'GL#'
       AND fst.id_flex_num                  = xso.chart_of_accounts_id
       AND fst.language                     =
                         NVL(xso.sla_description_language,SYS_CONTEXT('USERENV','LANG'))
       AND fsv.application_id               = 101
       AND fsv.id_flex_code                 = 'GL#'
       AND fsv.id_flex_num                  = xso.chart_of_accounts_id
       AND amt.accounting_method_code       = xso.sla_accounting_method_code
       AND amt.accounting_method_type_code  = xso.sla_accounting_method_type
       AND amt.language                     =
                         NVL(xso.sla_description_language,SYS_CONTEXT('USERENV','LANG'))
       AND amv.accounting_method_code       = xso.sla_accounting_method_code
       AND amv.accounting_method_type_code  = xso.sla_accounting_method_type
       AND fcu.currency_code                = xso.currency_code
       AND fla.language_code                     =
                         NVL(xso.sla_description_language,SYS_CONTEXT('USERENV','LANG'))
       AND gcm.coa_mapping_id(+)            = xso.sl_coa_mapping_id)
     ORDER BY xso.ledger_category_code;

CURSOR csr_alc_ledger (p_base_ledger_id        IN NUMBER) IS
   (SELECT xlr.target_ledger_id                 ledger_id
          ,xlr.name                             ledger_name
          ,xlr.currency_code                    ledger_currency
          ,fcu.precision                        ledger_currency_precision
          ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
                                                ledger_currency_mau
          -- the following is modified for bug 4640689
          ,decode(xsl.alc_enabled_flag
                 ,'Y',p_base_ledger_id
                 ,xlr.target_ledger_id)         sla_ledger_id
          ,nvl(xlr.ALC_INHERIT_CONVERSION_TYPE, 'Y') ALC_INHERIT_CONVERSION_TYPE
          ,xlr.ALC_DEFAULT_CONV_RATE_TYPE
          ,decode(xlr.ALC_NO_RATE_ACTION_CODE, 'FIND_RATE', nvl(xlr.ALC_MAX_DAYS_ROLL_RATE, -1), 0)
                                                ALC_MAX_DAYS_ROLL_RATE
      FROM xla_ledger_relationships_v  xlr
          ,fnd_currencies              fcu
          -- the following is added for bug 4640689
          ,xla_subledgers              xsl
     WHERE xlr.primary_ledger_id          = p_base_ledger_id
       AND xlr.relationship_enabled_flag  = 'Y'
       AND xlr.ledger_category_code       = 'ALC'
       AND fcu.currency_code              = xlr.currency_code
       AND xsl.application_id             = p_application_id);

CURSOR csr_ledger_pad
          (p_accounting_method_type            IN VARCHAR2
          ,p_accounting_method_code            IN VARCHAR2
          ,p_ledger_desc_language              IN VARCHAR2) IS
   (SELECT xmr.acctg_method_rule_id              rule_id
          ,xmr.amb_context_code                  amb_context_code
          ,xmr.product_rule_type_code            pad_type
          ,xmr.product_rule_code                 pad_code
          ,prt.name                              ledger_pad_name
          ,prv.name                              session_pad_name
          ,xpr.compile_status_code               compile_status
          ,xmr.start_date_active                 start_date
          ,xmr.end_date_active                   end_date
          ,xla_cmp_hash_pkg.BuildPackageName
              (p_application_id
              ,xmr.product_rule_code
              ,xmr.product_rule_type_code
              ,xmr.amb_context_code)          pad_package_name
      FROM xla_acctg_method_rules             xmr
          ,xla_product_rules_b                xpr
          ,xla_product_rules_tl               prt
          ,xla_product_rules_vl               prv
     WHERE xmr.application_id                 =  p_application_id
       AND xmr.accounting_method_type_code    =  p_accounting_method_type
       AND xmr.accounting_method_code         =  p_accounting_method_code
       AND xmr.amb_context_code               =  NVL(fnd_profile.value('XLA_AMB_CONTEXT'),'DEFAULT')
       AND NVL(xmr.start_date_active
              ,NVL(p_max_event_date
                  ,TRUNC(sysdate)
                  )
              )
                                              <= NVL(p_max_event_date,TRUNC(sysdate))
       AND xpr.application_id                 =  p_application_id
       AND xpr.amb_context_code               =  xmr.amb_context_code
       AND xpr.product_rule_type_code         =  xmr.product_rule_type_code
       AND xpr.product_rule_code              =  xmr.product_rule_code
       AND xpr.enabled_flag                   =  'Y'
       AND prt.application_id                 =  xpr.application_id
       AND prt.amb_context_code               =  xpr.amb_context_code
       AND prt.product_rule_type_code         =  xpr.product_rule_type_code
       AND prt.product_rule_code              =  xpr.product_rule_code
       AND prt.language                       =  p_ledger_desc_language
       AND prv.application_id                 =  xpr.application_id
       AND prv.amb_context_code               =  xpr.amb_context_code
       AND prv.product_rule_type_code         =  xpr.product_rule_type_code
       AND prv.product_rule_code              =  xpr.product_rule_code);

l_pad_count                 NUMBER;
l_application_name          VARCHAR2(240);
l_ledger_name               VARCHAR2(240);
l_base_ledger_count         NUMBER          := 0;
l_alc_ledger_count          NUMBER          := 0;
l_event_ledger_category     VARCHAR2(80);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.load_application_ledgers';
   END IF;

--   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure LOAD_APPLICATION_LEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_ledger_id = '||TO_CHAR(p_event_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_max_event_date = ' ||TO_CHAR(p_max_event_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- initializing all the variables
   ----------------------------------------------------------------------------
   g_record_session                   := NULL;
   g_primary_ledger_id                := NULL;
   g_base_ledger_ids.DELETE;
   g_alc_ledger_ids.DELETE;
   g_array_ledger.DELETE;
   g_array_sources.DELETE;
   g_array_event_classes.DELETE;
   g_array_event_types.DELETE;
   g_array_ledger_attrs.array_ledger_id.DELETE;
   g_array_ledger_attrs.array_ledger_type.DELETE;
   g_array_ledger_attrs.array_ledger_currency_code.DELETE;
   g_array_ledger_attrs.array_rounding_rule_code.DELETE;
   g_array_ledger_attrs.array_rounding_offset.DELETE;
   g_array_ledger_attrs.array_mau.DELETE;
   g_entered_currency_mau:= NULL;
   g_entered_currency_mau1:= NULL;
   g_entered_currency_mau2:= NULL;


   ----------------------------------------------------------------------------
   -- Caching application level information
   ----------------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Reading application level cache for application '||
                        TO_CHAR(p_application_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   SELECT TRUNC(sysdate)
         ,fnd_profile.value('USER_ID')
         ,xsl.application_id
         ,fav.application_short_name
         ,fav.application_name
         ,xsl.je_source_name
         ,jsv.user_je_source_name
         ,xsl.valuation_method_flag
         ,decode(nvl(xsl.control_account_type_code, 'N'), 'N', 'N', 'Y')
         ,xsl.alc_enabled_flag
     INTO g_record_session.date_sources('XLA_CREATION_DATE')
         ,g_record_session.num_sources('XLA_ENTRY_CREATED_BY')
         ,g_record_session.num_sources('XLA_EVENT_APPL_ID')
         ,g_record_session.char_sources('XLA_EVENT_APPL_SHORT_NAME')
         ,g_record_session.char_sources_sl('XLA_EVENT_APPL_NAME')
         ,g_record_session.char_sources('XLA_JE_SOURCE_NAME')
         ,g_record_session.char_sources_sl('XLA_USER_JE_SOURCE_NAME')
         ,g_record_session.char_sources('VALUATION_METHOD_FLAG')
         ,g_record_session.char_sources('CONTROL_ACCOUNT_ENABLED_FLAG')
         ,g_record_session.char_sources('XLA_ALC_ENABLED_FLAG')
     FROM xla_subledgers           xsl
         ,fnd_application_vl       fav
         ,gl_je_sources_vl         jsv
    WHERE xsl.application_id       = p_application_id
      AND fav.application_id       = xsl.application_id
      AND jsv.je_source_name       = xsl.je_source_name;

   IF SQL%NOTFOUND THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: Problem in caching the session level sources '||
                           'for the application. application ID = '||TO_CHAR(p_application_id)
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);
      END IF;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'Problem in caching the session level sources for the application.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'load_application_ledgers');
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'xla_event_appl_short_name = '||
                        g_record_session.char_sources('XLA_EVENT_APPL_SHORT_NAME')
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'xla_creation_date = '||
                        TO_CHAR(g_record_session.date_sources('XLA_CREATION_DATE'))
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'xla_entry_created_by = '||
                        TO_CHAR(g_record_session.num_sources('XLA_ENTRY_CREATED_BY'))
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'application_id = '||
                        TO_CHAR(g_record_session.num_sources('XLA_EVENT_APPL_ID'))
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'valuation_method_flag = '||
                        g_record_session.char_sources('VALUATION_METHOD_FLAG')
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'control_account_enabled_flag = '||
                        g_record_session.char_sources('CONTROL_ACCOUNT_ENABLED_FLAG')
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'xla_alc_enabled_flag= '||
                        g_record_session.char_sources('XLA_ALC_ENABLED_FLAG')
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- Caching base ledger information
   ----------------------------------------------------------------------------
   --
   -- >> valuation method enhanacements
   --
   SELECT ledger_category_code
     INTO l_event_ledger_category
     FROM gl_ledgers
    WHERE ledger_id = p_event_ledger_id;
   --
   -- << valuation method enhanacements
   --

   FOR c1 IN csr_base_ledger (l_event_ledger_category) LOOP
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      =>'Reading ledger level cache for ledger '||TO_CHAR(c1.ledger_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------
      -- Storing ledger_id in an array
      -------------------------------------------------------------------------
      l_base_ledger_count := l_base_ledger_count +1;
      g_base_ledger_ids(l_base_ledger_count) := c1.ledger_id;

      -------------------------------------------------------------------------
      -- Storing category code in array to efficiently know the ledger
      -- category
      -------------------------------------------------------------------------
      g_array_ledger(c1.ledger_id).category_code     := c1.ledger_category_code;

      -------------------------------------------------------------------------
      -- Caching translated information
      -------------------------------------------------------------------------
      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_EVENT_APPL_NAME') := c1.application_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_USER_JE_SOURCE_NAME') := c1.user_je_source_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_LEDGER_NAME') := c1.ledger_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_COA_NAME') := c1.ledger_coa_name;

      g_array_ledger(c1.ledger_id)
                .char_sources_sl('XLA_COA_NAME') := c1.session_coa_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_ACCOUNTING_METHOD_NAME') := c1.ledger_slam_name;

      g_array_ledger(c1.ledger_id)
                .char_sources_sl('XLA_ACCOUNTING_METHOD_NAME') := c1.session_slam_name;


      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      =>'application_name = '||c1.application_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'user_je_source_name = '||c1.user_je_source_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'ledger_name = '||c1.ledger_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'ledger_coa_name = '||c1.ledger_coa_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'session_coa_name = '||c1.session_coa_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'ledger_slam_name = '||c1.ledger_slam_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'session_slam_name = '||c1.session_slam_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------
      -- Caching untranslated information
      -------------------------------------------------------------------------
      g_array_ledger(c1.ledger_id)
                .char_sources('DYNAMIC_INSERTS_ALLOWED_FLAG') := c1.dynamic_inserts_allowed_flag;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_COA_ID') := c1.coa_id;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_ACCOUNTING_METHOD_OWNER') := c1.slam_type;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_CURRENCY_CODE') := c1.xla_currency_code;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_DESCRIPTION_LANGUAGE') := c1.xla_description_language;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_NLS_DESC_LANGUAGE') := c1.xla_nls_desc_language;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_ENTERED_CUR_BAL_SUS_CCID') := c1.xla_entered_cur_bal_sus_ccid;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_LEDGER_CUR_BAL_SUS_CCID') := c1.xla_ledger_cur_bal_sus_ccid;

      g_array_ledger(c1.ledger_id)
                .num_sources('RES_ENCUMB_CODE_COMBINATION_ID') := c1.res_encumb_code_combination_id;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_ROUNDING_CCID') := c1.xla_rounding_ccid;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_MAX_DAYS_ROLL_RATE') := c1.ALC_MAX_DAYS_ROLL_RATE;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_INHERIT_CONVERSION_TYPE') := c1.ALC_INHERIT_CONVERSION_TYPE;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_DEFAULT_CONV_RATE_TYPE') := c1.ALC_DEFAULT_CONV_RATE_TYPE;

      g_array_ledger(c1.ledger_id)
                .char_sources('LEDGER_CATEGORY_CODE') := c1.ledger_category_code;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_CURRENCY_PRECISION') := c1.ledger_currency_precision;

      g_array_ledger(c1.ledger_id)
                .num_sources('XLA_CURRENCY_MAU') := c1.ledger_currency_mau;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_ROUNDING_RULE_CODE') := c1.xla_rounding_rule_code;

      g_array_ledger(c1.ledger_id)
                .num_sources('SL_COA_MAPPING_ID') := c1.coa_mapping_id;

      g_array_ledger(c1.ledger_id)
                .char_sources('GL_COA_MAPPING_NAME') := c1.coa_mapping_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('BAL_SEG_COLUMN_NAME') := c1.bal_seg_column_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('MGT_SEG_COLUMN_NAME') := c1.mgt_seg_column_name;

      g_array_ledger(c1.ledger_id)
                .char_sources('SLA_BAL_BY_LEDGER_CURR_FLAG') := c1.xla_ledger_cur_bal_flag;

      g_array_ledger(c1.ledger_id)
                .char_sources('XLA_ACCT_REVERSAL_OPTION') := c1.xla_acct_reversal_option_code;

      g_array_ledger(c1.ledger_id)
                .num_sources('SLA_LEDGER_ID') := c1.sla_ledger_id ;

      g_array_ledger(c1.ledger_id)
                .num_sources('LATEST_ENCUMBRANCE_YEAR') := c1.latest_encumbrance_year;

      g_array_ledger(c1.ledger_id)
                .char_sources('BAL_SEG_VALUE_OPTION_CODE') := c1.bal_seg_value_option_code;

      g_array_ledger(c1.ledger_id)
                .char_sources('MGT_SEG_VALUE_OPTION_CODE') := c1.mgt_seg_value_option_code;

      g_array_ledger(c1.ledger_id)
                .char_sources('ALLOW_INTERCOMPANY_POST_FLAG') := c1.allow_intercompany_post_flag;

      g_array_ledger(c1.ledger_id)
                .num_sources('TRANSACTION_CALENDAR_ID') := c1.transaction_calendar_id;

      g_array_ledger(c1.ledger_id)
                .char_sources('ENABLE_AVERAGE_BALANCES_FLAG') := c1.enable_average_balances_flag;

      g_array_ledger(c1.ledger_id)
                .char_sources('EFFECTIVE_DATE_RULE_CODE') := c1.effective_date_rule_code;

      g_array_ledger(c1.ledger_id)
                .char_sources('SUSPENSE_ALLOWED_FLAG') := c1.suspense_allowed_flag;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      =>'dynamic_inserts_allowed_flag = '||c1.dynamic_inserts_allowed_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'coa_id = '||TO_CHAR(c1.coa_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'slam_type = '||c1.slam_type
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_currency_code = '||c1.xla_currency_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_description_language = '||c1.xla_description_language
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_nls_desc_language = '||c1.xla_nls_desc_language
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_entered_cur_bal_sus_ccid = '||TO_CHAR(c1.xla_entered_cur_bal_sus_ccid)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_ledger_cur_bal_sus_ccid = '||TO_CHAR(c1.xla_ledger_cur_bal_sus_ccid)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'res_encumb_code_combination_id = '||TO_CHAR(c1.res_encumb_code_combination_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'ledger_category_code = '||c1.ledger_category_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'ledger_currency_precision = '||TO_CHAR(c1.ledger_currency_precision)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'coa_mapping_id = '||TO_CHAR(c1.coa_mapping_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'coa_mapping_name = '||c1.coa_mapping_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'bal_seg_column_name = '||c1.bal_seg_column_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'mgt_seg_column_name = '||c1.mgt_seg_column_name
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_ledger_cur_bal_flag = '||c1.xla_ledger_cur_bal_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'xla_acct_reversal_option_code = '||c1.xla_acct_reversal_option_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'sla_ledger_id = '||TO_CHAR(c1.sla_ledger_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'latest_encumbrance_year = '||TO_CHAR(c1.latest_encumbrance_year)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'bal_seg_value_option_code = '||c1.bal_seg_value_option_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'mgt_seg_value_option_code = '||c1.mgt_seg_value_option_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'allow_intercompany_post_flag = '||c1.allow_intercompany_post_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'transaction_calendar_id = '||c1.transaction_calendar_id
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'enable_average_balance_flag = '||c1.enable_average_balances_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         trace
            (p_msg      =>'effective_date_rule_code = '||c1.effective_date_rule_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------
      -- Caching alc ledger ids only if base ledger is a primary ledger. There
      -- cannot be ALC ledgers for a secondary ledger
      -------------------------------------------------------------------------
      IF c1.ledger_category_code = 'PRIMARY' THEN
         g_primary_ledger_id := c1.ledger_id;

	 --8238617
	 g_primary_ledger_currency := c1.xla_currency_code;

         ----------------------------------------------------------------------
         -- Caching currecny information for alc ledgers
         ----------------------------------------------------------------------
         FOR c2 IN csr_alc_ledger (c1.ledger_id) LOOP
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      =>'Caching information for alc ledger = '||TO_CHAR(c2.ledger_id)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
            END IF;
            -------------------------------------------------------------------------
            -- Storing ledger_id in an array
            -------------------------------------------------------------------------
            l_alc_ledger_count := l_alc_ledger_count + 1;
            g_alc_ledger_ids(l_alc_ledger_count) := c2.ledger_id;

            -------------------------------------------------------------------------
            -- Storing category code in array to efficiently know the ledger
            -- category
            -------------------------------------------------------------------------
            g_array_ledger(c2.ledger_id).category_code       := 'ALC';

            g_array_ledger(c2.ledger_id)
                .char_sources('LEDGER_CATEGORY_CODE') := 'ALC';

            g_array_ledger(c2.ledger_id)
                 .char_sources('XLA_LEDGER_NAME') := c2.ledger_name;

            g_array_ledger(c2.ledger_id)
                 .char_sources('XLA_CURRENCY_CODE') := c2.ledger_currency;

            g_array_ledger(c2.ledger_id)
                 .num_sources('XLA_CURRENCY_PRECISION') := c2.ledger_currency_precision;

            g_array_ledger(c2.ledger_id)
                 .num_sources('XLA_CURRENCY_MAU') := c2.ledger_currency_mau;

            g_array_ledger(c2.ledger_id)
                .num_sources('XLA_MAX_DAYS_ROLL_RATE') := c2.ALC_MAX_DAYS_ROLL_RATE;

            g_array_ledger(c2.ledger_id)
                .char_sources('XLA_INHERIT_CONVERSION_TYPE') := c2.ALC_INHERIT_CONVERSION_TYPE;

            g_array_ledger(c2.ledger_id)
                .char_sources('XLA_DEFAULT_CONV_RATE_TYPE') := c2.ALC_DEFAULT_CONV_RATE_TYPE;


            g_array_ledger(c2.ledger_id)
                 .num_sources('SLA_LEDGER_ID') := c2.sla_ledger_id;

            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                  (p_msg      =>'ledger_category_code = ALC'
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
               trace
                  (p_msg      =>'ledger_currency = '||c2.ledger_currency
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
               trace
                  (p_msg      =>'ledger_currency_precision = '||TO_CHAR(c2.ledger_currency_precision)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
               trace
                  (p_msg      =>'sla_ledger_id = '||TO_CHAR(c2.sla_ledger_id)
                  ,p_level    => C_LEVEL_STATEMENT
                  ,p_module   => l_log_module);
            END IF;

         END LOOP;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      =>'Number of alc ledgers = '||TO_CHAR(g_alc_ledger_ids.COUNT)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
      END IF;

      -------------------------------------------------------------------------
      -- Caching PAD information for the ledger
      -------------------------------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Caching product definitions for the ledger '||
                           TO_CHAR(c1.ledger_id)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      l_pad_count := 0;
      FOR c2 IN csr_ledger_pad (c1.slam_type
                               ,c1.slam_code
                               ,c1.xla_description_language)
      LOOP
         l_pad_count := l_pad_count + 1;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .acctg_method_rule_id    := c2.rule_id;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .amb_context_code        := c2.amb_context_code;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .product_rule_owner      := c2.pad_type;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .product_rule_code       := c2.pad_code;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .ledger_product_rule_name       := c2.ledger_pad_name;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .session_product_rule_name       := c2.session_pad_name;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .pad_package_name        := c2.pad_package_name;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .compile_status_code     := c2.compile_status;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .start_date_active       := c2.start_date;

         g_array_ledger(c1.ledger_id)
              .pads(l_pad_count)
              .end_date_active         := c2.end_date;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      =>'rule_id = '||TO_CHAR(c2.rule_id)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'amb_context_code = '||c2.amb_context_code
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'pad_type = '||c2.pad_type
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'pad_code = '||c2.pad_code
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'ledger_pad_name = '||c2.ledger_pad_name
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'session_pad_name = '||c2.session_pad_name
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'pad_package_name = '||c2.pad_package_name
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'compile_status = '||c2.compile_status
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'start_date = '||TO_CHAR(c2.start_date)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            trace
               (p_msg      =>'end_date = '||TO_CHAR(c2.end_date)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;

      END LOOP;

      IF g_array_ledger.EXISTS(c1.ledger_id) THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      =>'Number of PADs = '||
                             TO_CHAR(g_array_ledger(c1.ledger_id).pads.COUNT)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
      END IF;

   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      =>'Number of base ledgers = '||TO_CHAR(g_base_ledger_ids.COUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF g_base_ledger_ids.count = 0 THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: Problem in caching ledgers. Probably the ledger '||
                           'setup is incomplete. ledger ID = '||TO_CHAR(p_event_ledger_id)
            ,p_level    => C_LEVEL_ERROR
            ,p_module   => l_log_module);
      END IF;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_COMMON_ERROR'
         ,p_token_1        => 'ERROR'
         ,p_value_1        => 'There is problem in caching the ledger. '||
                              'Probably, the ledger setup is not complete.'
         ,p_token_2        => 'LOCATION'
         ,p_value_2        => 'load_application_ledgers');
   END IF;

   ----------------------------------------------------------------------------
   -- Call routine to cache application setups
   ----------------------------------------------------------------------------
   cache_application_setup
      (p_application_id      => p_application_id
      ,p_ledger_id           => p_event_ledger_id
      ,p_ledger_category     => l_event_ledger_category); --pass ledger category also Bug #4554935

   ----------------------------------------------------------------------------
   -- Call routine to cache defined system sources
   ----------------------------------------------------------------------------
   load_system_sources;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure LOAD_APPLICATION_LEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
-- Bug 5018098
WHEN NO_DATA_FOUND THEN
  IF csr_base_ledger%NOTFOUND THEN
     xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'ERROR: Problem getting ledger information for application '||p_application_id||'. '||
                                  'Subledger Accounting Options are not defined for this ledger and application.
                                   Please run Update Subledger Accounting Options program for your application.'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_cache_pkg.load_application_ledgers');
  END IF;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END load_application_ledgers;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_pad_info
       (p_ledger_id                  IN  NUMBER
       ,p_event_date                 IN  DATE
       ,p_pad_owner                  OUT NOCOPY VARCHAR2
       ,p_pad_code                   OUT NOCOPY VARCHAR2
       ,p_ledger_pad_name            OUT NOCOPY VARCHAR2
       ,p_session_pad_name           OUT NOCOPY VARCHAR2
       ,p_pad_compile_status         OUT NOCOPY VARCHAR2
       ,p_pad_package_name           OUT NOCOPY VARCHAR2) IS
l_ledger_id                 NUMBER;
l_pad_found                 BOOLEAN    := FALSE;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_pad_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_PAD_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '  ||TO_CHAR(p_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_date = '||TO_CHAR(p_event_date)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_ledger_id := p_ledger_id;

   IF (g_array_ledger(l_ledger_id).category_code = 'ALC')
   THEN
      l_ledger_id := g_primary_ledger_id;
   END IF;

   ----------------------------------------------------------------------------
   -- PAD start date and end date could be null. PAD effective dates must be
   -- compared using NVL.
   ----------------------------------------------------------------------------
   FOR i in 1..g_array_ledger(l_ledger_id).pads.COUNT LOOP
      IF (p_event_date >=
               NVL(g_array_ledger(l_ledger_id).pads(i).start_date_active, p_event_date-1)
         )
         AND
         (p_event_date <=
               NVL(g_array_ledger(p_ledger_id).pads(i).end_date_active, p_event_date+1)
         )
      THEN
         p_pad_owner          := g_array_ledger(l_ledger_id)
                                     .pads(i).product_rule_owner;
         p_pad_code           := g_array_ledger(l_ledger_id)
                                     .pads(i).product_rule_code;
         p_ledger_pad_name    := g_array_ledger(l_ledger_id)
                                     .pads(i).ledger_product_rule_name;
         p_session_pad_name   := g_array_ledger(l_ledger_id)
                                     .pads(i).session_product_rule_name;
         p_pad_compile_status := g_array_ledger(l_ledger_id)
                                     .pads(i).compile_status_code;
         p_pad_package_name   := g_array_ledger(l_ledger_id)
                                     .pads(i).pad_package_name;
         l_pad_found := TRUE;
         EXIT;
      END IF;
   END LOOP;

   IF NOT l_pad_found THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'WARNNING: No PAD found for : '||
                           'ledger = '||TO_CHAR(p_ledger_id)||
                           ' and event date = '||TO_CHAR(p_event_date)
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_pad_owner = '||p_pad_owner
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_pad_code = '||p_pad_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_pad_name = '||p_ledger_pad_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_session_pad_name = '||p_session_pad_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_pad_compile_status = '||p_pad_compile_status
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_pad_package_name = '||p_pad_package_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure GET_PAD_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END get_pad_info;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_event_info
        (p_ledger_id                  IN  NUMBER
        ,p_event_class_code           IN  VARCHAR2
        ,p_event_type_code            IN  VARCHAR2
        ,p_ledger_event_class_name    OUT NOCOPY VARCHAR2
        ,p_session_event_class_name   OUT NOCOPY VARCHAR2
        ,p_ledger_event_type_name     OUT NOCOPY VARCHAR2
        ,p_session_event_type_name    OUT NOCOPY VARCHAR2) IS
l_ledger_id                 NUMBER;
l_language                  VARCHAR2(30);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_event_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_EVENT_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '  ||TO_CHAR(p_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_type_code = '||p_event_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_ledger_id := p_ledger_id;

   IF (g_array_ledger(l_ledger_id).category_code = 'ALC')
   THEN
      l_ledger_id := g_primary_ledger_id;
   END IF;

   l_language := g_array_ledger(l_ledger_id).char_sources('XLA_DESCRIPTION_LANGUAGE');

   p_ledger_event_class_name  := g_array_event_classes(p_event_class_code)
                                         .event_class_name_tl(l_language);
   p_ledger_event_type_name   := g_array_event_types(p_event_type_code)
                                         .event_type_name_tl(l_language);
   p_session_event_class_name := g_array_event_classes(p_event_class_code)
                                         .event_class_name_sl;
   p_session_event_type_name  := g_array_event_types(p_event_type_code)
                                         .event_type_name_sl;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_ledger_event_class_name = '||p_ledger_event_class_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_session_event_class_name = '||p_session_event_class_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_event_type_name = '||p_ledger_event_type_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_session_event_type_name = '||p_session_event_type_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure GET_EVENT_INFO'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END get_event_info;


--=============================================================================
--
-- get values from accounting cache
--
--=============================================================================
FUNCTION GetValueNum
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN NUMBER IS
l_ledger_id                 NUMBER;
l_value                     NUMBER;
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueNum';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUENUM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_target_ledger_id = '||TO_CHAR(p_target_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'D')
   THEN
      l_ledger_id := p_target_ledger_id;

      IF ((g_array_ledger(l_ledger_id).category_code = 'ALC') AND
          (NOT(g_array_ledger(l_ledger_id).num_sources.EXISTS(p_source_code))))
      THEN
         l_ledger_id := g_primary_ledger_id;
      END IF;

      l_value := g_array_ledger(l_ledger_id).num_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUENUM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueNum;


--=============================================================================
--
-- get values from accounting cache
--
--=============================================================================
FUNCTION GetValueNum
       (p_source_code                IN VARCHAR2)
RETURN NUMBER IS
l_value                     NUMBER;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueNum';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUENUM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'D')
   THEN
      l_value := g_record_session.num_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUENUM'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueNum;



--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetValueDate
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN DATE IS
l_ledger_id                 NUMBER;
l_value                     DATE;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueDate';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUEDATE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_target_ledger_id = '||TO_CHAR(p_target_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'D')
   THEN
      l_ledger_id := p_target_ledger_id;
      IF ((g_array_ledger(l_ledger_id).category_code = 'ALC') AND
          (NOT(g_array_ledger(l_ledger_id).date_sources.EXISTS(p_source_code))))
      THEN
         l_ledger_id := g_primary_ledger_id;
      END IF;

      l_value := g_array_ledger(l_ledger_id).date_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUEDATE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueDate;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetValueDate
       (p_source_code                IN VARCHAR2)
RETURN DATE IS
l_value                     DATE;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueDate';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUEDATE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'D')
   THEN
      l_value := g_record_session.date_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUEDATE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueDate;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetValueChar
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN VARCHAR2 IS
l_ledger_id                 NUMBER;
l_value                     VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueChar';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_target_ledger_id = '||TO_CHAR(p_target_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'C')
   THEN
      l_ledger_id := p_target_ledger_id;
      IF ((g_array_ledger(l_ledger_id).category_code = 'ALC') AND
          (NOT(g_array_ledger(l_ledger_id).char_sources.EXISTS(p_source_code))))
      THEN
         l_ledger_id := g_primary_ledger_id;
      END IF;

      l_value := g_array_ledger(l_ledger_id).char_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueChar;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetValueChar
       (p_source_code                IN VARCHAR2)
RETURN VARCHAR2 IS
l_value                     VARCHAR2(240);
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueChar';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'C')
   THEN
      l_value := g_record_session.char_sources(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetValueChar;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetSessionValueChar
       (p_source_code                IN VARCHAR2
       ,p_target_ledger_id           IN NUMBER)
RETURN VARCHAR2 IS
l_ledger_id                 NUMBER;
l_value                     VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSessionValueChar';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETSESSIONVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_target_ledger_id = '||TO_CHAR(p_target_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'C')
   THEN
      l_ledger_id := p_target_ledger_id;

      IF ((g_array_ledger(l_ledger_id).category_code = 'ALC') AND
          (NOT(g_array_ledger(l_ledger_id).char_sources_sl.EXISTS(p_source_code))))
      THEN
         l_ledger_id := g_primary_ledger_id;
      END IF;

      l_value := g_array_ledger(l_ledger_id).char_sources_sl(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETSESSIONVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetSessionValueChar;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetSessionValueChar
       (p_source_code                IN VARCHAR2)
RETURN VARCHAR2 IS
l_value                     VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSessionValueChar';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETSESSIONVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '  ||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF is_source_valid
         (p_source_code  => p_source_code
         ,p_datatype     => 'C')
   THEN
      l_value := g_record_session.char_sources_sl(p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_value)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETSESSIONVALUECHAR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetSessionValueChar;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetAlcLedgers
       (p_primary_ledger_id          IN NUMBER)
RETURN t_array_ledger_id IS
l_array_alc_ledgers         t_array_ledger_id;
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAlcLedgers';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETALCLEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_primary_ledger_id = '||TO_CHAR(p_primary_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF p_primary_ledger_id = g_primary_ledger_id THEN
      l_array_alc_ledgers := g_alc_ledger_ids;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Count of alc ledgers returned = '||
                         TO_CHAR(l_array_alc_ledgers.COUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETALCLEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_array_alc_ledgers;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetAlcLedgers;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetLedgers
RETURN t_array_ledger_id IS
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLedgers';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETLEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Count of ledgers returned = '||
                         TO_CHAR(g_base_ledger_ids.COUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETLEDGERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN g_base_ledger_ids;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetLedgers;



--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_je_category
        (p_ledger_id                  IN  NUMBER
        ,p_event_class_code           IN  VARCHAR2)
RETURN VARCHAR2 IS
l_ledger_id                 NUMBER;
l_je_category               VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_je_category';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GET_JE_CATEGORY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '  ||TO_CHAR(p_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_ledger_id := p_ledger_id;

   IF (g_array_ledger(l_ledger_id).category_code = 'ALC')
   THEN
      l_ledger_id := g_primary_ledger_id;
   END IF;

   l_je_category := g_array_event_classes(p_event_class_code)
                         .xla_je_category(l_ledger_id);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Return Value = '||l_je_category
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GET_JE_CATEGORY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_je_category;
EXCEPTION
-- Bug 4736579
WHEN NO_DATA_FOUND THEN
     xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'ERROR: Problem getting journal category information for '||p_event_class_code||' and ledger '||p_ledger_id||'. '||
                                  'Subledger Accounting Options are not defined for the ledger and your application.'||
                                  'Please run Update Subledger Accounting Options program for your application.'

            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_cache_pkg.get_je_category');

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END get_je_category;



--=============================================================================
--
--
--
--=============================================================================
FUNCTION GetArrayPad
       (p_ledger_id                  IN  NUMBER -- primary/secondary ledger id
       ,p_max_event_date             IN  DATE
       ,p_min_event_date             IN  DATE)
RETURN t_array_pad IS
l_ledger_id                 NUMBER;
l_array_pads                t_array_pad;
l_pad_found                 BOOLEAN    := FALSE;
l_log_module                VARCHAR2(240);
j                           NUMBER := 0;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetArrayPad';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function GETARRAYPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_max_event_date = '||p_max_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_min_event_date = '||p_min_event_date
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_ledger_id := p_ledger_id;

   IF (g_array_ledger(l_ledger_id).category_code = 'ALC')
   THEN
      l_ledger_id := g_primary_ledger_id;
   END IF;

   ----------------------------------------------------------------------------
   -- PAD start date and end date could be null. PAD effective dates must be
   -- compared using NVL.
   ----------------------------------------------------------------------------
   FOR i in 1..g_array_ledger(l_ledger_id).pads.COUNT LOOP
      IF (p_min_event_date <=
               NVL(g_array_ledger(l_ledger_id).pads(i).end_date_active, p_min_event_date+1)
         )
         AND
         (p_max_event_date >=
               NVL(g_array_ledger(p_ledger_id).pads(i).start_date_active, p_max_event_date-1)
         )
      THEN
         j := j + 1;
         l_array_pads(j).acctg_method_rule_id := g_array_ledger(l_ledger_id)
                                     .pads(i).acctg_method_rule_id;
         l_array_pads(j).amb_context_code := g_array_ledger(l_ledger_id)
                                     .pads(i).amb_context_code;
         l_array_pads(j).product_rule_owner := g_array_ledger(l_ledger_id)
                                     .pads(i).product_rule_owner;
         l_array_pads(j).product_rule_code := g_array_ledger(l_ledger_id)
                                     .pads(i).product_rule_code;
         l_array_pads(j).ledger_product_rule_name := g_array_ledger(l_ledger_id)
                                     .pads(i).ledger_product_rule_name;
         l_array_pads(j).session_product_rule_name := g_array_ledger(l_ledger_id)
                                     .pads(i).session_product_rule_name;
         l_array_pads(j).compile_status_code := g_array_ledger(l_ledger_id)
                                     .pads(i).compile_status_code;
         l_array_pads(j).pad_package_name   := g_array_ledger(l_ledger_id)
                                     .pads(i).pad_package_name;
         l_array_pads(j).start_date_active := g_array_ledger(l_ledger_id)
                                     .pads(i).start_date_active;
         l_array_pads(j).end_date_active := g_array_ledger(l_ledger_id)
                                     .pads(i).end_date_active;
      END IF;
   END LOOP;

   IF l_array_pads.COUNT = 0 THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'WARNNING: No PAD found for : '||
                           'ledger = '||TO_CHAR(p_ledger_id)||
                           ' and date between '||TO_CHAR(p_min_event_date)||
                           ' and '||TO_CHAR(p_max_event_date)
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Count of pads = '||l_array_pads.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETARRAYPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
return l_array_pads;
END GetArrayPad;


--=============================================================================
--          *********** local procedures and functions **********
--=============================================================================

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
-- Following are local routines
--
--    1.    cache_application_setup
--    2.    load_system_sources
--    3.    is_source_valid
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
--
--
--
--=============================================================================
PROCEDURE cache_application_setup
   (p_application_id                  IN  INTEGER
   ,p_ledger_id                       IN  INTEGER
   ,p_ledger_category                 IN  VARCHAR2) IS

CURSOR csr_event_class IS
   SELECT ect.event_class_code      event_class_code
         ,ect.name                  ledger_event_class_name
         ,ecv.name                  session_event_class_name
         ,ect.language              language
     FROM xla_subledger_options_v   xso
         ,xla_event_classes_tl      ect
         ,xla_event_classes_vl      ecv
    WHERE xso.application_id          = p_application_id
      AND DECODE(xso.valuation_method_flag
                ,'N',xso.primary_ledger_id
                ,xso.ledger_id)       = p_ledger_id
      AND xso.enabled_flag            = 'Y'
      AND ect.application_id          = p_application_id
      AND ect.language               IN
                 (NVL(xso.sla_description_language,USERENV('LANG'))
                 ,USERENV('LANG'))
      AND ecv.application_id          = p_application_id
      AND ecv.event_class_code        = ect.event_class_code
   GROUP BY ect.event_class_code
           ,ecv.name
           ,ect.language
           ,ect.name;

CURSOR csr_je_category(x_event_ledger_category IN VARCHAR2) IS
   SELECT xjc.event_class_code      event_class_code
         ,xjc.je_category_name      je_category_name
         ,xso.ledger_id             ledger_id
     FROM xla_subledger_options_v   xso
         ,xla_je_categories         xjc
    WHERE xso.application_id          = p_application_id
      AND xso.enabled_flag            = 'Y'
      AND xjc.application_id          = p_application_id
      AND xjc.ledger_id               = xso.ledger_id
      AND DECODE(x_event_ledger_category
                 ,'PRIMARY',xso.primary_ledger_id
                 ,xso.ledger_id)            = p_ledger_id
      AND DECODE(x_event_ledger_category
                 ,'PRIMARY',DECODE(xso.ledger_category_code
                                  ,'PRIMARY','Y','N')
                 ,'Y')                      = xso.capture_event_flag;



CURSOR csr_event_type IS
   SELECT ett.event_type_code       event_type_code
         ,ett.name                  ledger_event_type_name
         ,etv.name                  session_event_type_name
         ,ett.language              language
     FROM xla_subledger_options_v   xso
         ,xla_event_types_tl        ett
         ,xla_event_types_vl        etv
    WHERE xso.application_id          = p_application_id
      AND DECODE(xso.valuation_method_flag
                ,'N',xso.primary_ledger_id
                ,xso.ledger_id)       = p_ledger_id
      AND xso.enabled_flag            = 'Y'
      AND ett.application_id          = p_application_id
      AND ett.language               IN
                 (NVL(xso.sla_description_language,USERENV('LANG'))
                 ,USERENV('LANG'))
      AND etv.application_id          = p_application_id
      AND etv.event_type_code         = ett.event_type_code
   GROUP BY ett.event_type_code
           ,etv.name
           ,ett.language
           ,ett.name;

l_log_module                VARCHAR2(240);
l_event_ledger_category     VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_application_setup';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure CACHE_APPLICATION_SETUP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||TO_CHAR(p_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||TO_CHAR(p_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   l_event_ledger_category := p_ledger_category;

   FOR c1 IN csr_event_class LOOP
      g_array_event_classes(c1.event_class_code)
               .event_class_name_tl(c1.language) := c1.ledger_event_class_name;
      g_array_event_classes(c1.event_class_code)
               .event_class_name_sl := c1.session_event_class_name;
   END LOOP;

   ----------------------------------------------------------------------------
   -- following is added to cache je_categories defined for a event_class and
   -- ledger. (bug # 3109690)
   ----------------------------------------------------------------------------
   FOR c1 IN csr_je_category(l_event_ledger_category) LOOP
      g_array_event_classes(c1.event_class_code)
               .xla_je_category(c1.ledger_id) := c1.je_category_name;
   END LOOP;

   FOR c1 IN csr_event_type LOOP
      g_array_event_types(c1.event_type_code)
               .event_type_name_tl(c1.language) := c1.ledger_event_type_name;
      g_array_event_types(c1.event_type_code)
               .event_type_name_sl := c1.session_event_type_name;
   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of event classes = '||TO_CHAR(g_array_event_classes.COUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'Number of event types = '||TO_CHAR(g_array_event_types.COUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Procedure CACHE_APPLICATION_SETUP'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END cache_application_setup;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE load_system_sources IS
CURSOR csr_sources IS
   SELECT source_code
         ,datatype_code
     FROM xla_sources_b WHERE application_id = 602;

l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.load_system_sources';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of Procedure LOAD_SYSTEM_SOURCES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FOR c1 IN csr_sources LOOP
      g_array_sources(c1.source_code) := c1.datatype_code;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of Procedure LOAD_SYSTEM_SOURCES'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END load_system_sources;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION is_source_valid
       (p_source_code         IN VARCHAR2
       ,p_datatype            IN VARCHAR2)
RETURN BOOLEAN IS
l_return_value              BOOLEAN  := FALSE;
l_dummy_value               VARCHAR2(30);
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_source_valid';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of function IS_SOURCE_VALID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_source_code = '||p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_datatype = '||p_datatype
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF g_array_sources.EXISTS(p_source_code) THEN
      l_return_value := TRUE;
      l_dummy_value  := 'TRUE';
   ELSE
      l_dummy_value  := 'FALSE';
      xla_exceptions_pkg.raise_message
         (p_appli_s_name   => 'XLA'
         ,p_msg_name       => 'XLA_AP_INVALID_SOURCE_CODE'
         ,p_token_1        => 'SOURCE_CODE'
         ,p_value_1        => p_source_code);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value = '||l_dummy_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function IS_SOURCE_VALID'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_return_value;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END is_source_valid;

Procedure BuildLedgerArray
( p_array_ledger_attrs OUT NOCOPY t_array_ledger_attrs)
IS
l_log_module                VARCHAR2(240);
l_count                     NUMBER :=0;
l_rounding_offset           NUMBER;
l_rounding_rule_code        VARCHAR2(30);
l_pri_rounding_offset           NUMBER;
l_pri_rounding_rule_code        VARCHAR2(30);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.BuildLedgerArray';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of Procedure BuildLedgerArray'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  IF(g_array_ledger_attrs.array_ledger_id.COUNT>0) THEN
    p_array_ledger_attrs := g_array_ledger_attrs;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Already built, END of function BuildLedgerArray'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

    RETURN;
  END IF;

  FOR Idx IN g_base_ledger_ids.FIRST .. g_base_ledger_ids.LAST LOOP

    l_rounding_rule_code :=xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx)
                         );
    IF l_rounding_rule_code = 'NEAREST' THEN
      l_rounding_offset := 0;
    ELSIF l_rounding_rule_code = 'UP' THEN
      l_rounding_offset := .5-power(10, -30);
    ELSIF l_rounding_rule_code = 'DOWN' THEN
      l_rounding_offset :=-(.5-power(10, -30));
    ELSE
      l_rounding_offset := 0;
    END IF;

    l_count:=l_count+1;

    g_array_ledger_attrs.array_default_rate_type(l_count) :=
                          xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_DEFAULT_CONV_RATE_TYPE'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx)
                         );
    g_array_ledger_attrs.array_inhert_type_flag(l_count) :=
                          xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_INHERIT_CONVERSION_TYPE'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx)
                         );
    g_array_ledger_attrs.array_max_roll_date(l_count) :=
                          xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_MAX_DAYS_ROLL_RATE'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx)
                         );
    g_array_ledger_attrs.array_ledger_id(l_count) := g_base_ledger_ids(Idx);
    g_array_ledger_attrs.array_ledger_currency_code(l_count):=
                     xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_CURRENCY_CODE'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx));
    g_array_ledger_attrs.array_mau(l_count):=
                     xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_base_ledger_ids(Idx));
    g_array_ledger_attrs.array_rounding_rule_code(l_count):=
                     l_rounding_rule_code;

    g_array_ledger_attrs.array_rounding_offset(l_count):= l_rounding_offset;

    IF (g_primary_ledger_id = g_base_ledger_ids(Idx)) THEN
      g_array_ledger_attrs.array_ledger_type(l_count):= 'PRIMARY';
      l_pri_rounding_rule_code := l_rounding_rule_code;
      l_pri_rounding_offset := l_rounding_offset;
    ELSE
      g_array_ledger_attrs.array_ledger_type(l_count) := 'SECONDARY';
    END IF;
  END LOOP;

  IF(g_alc_ledger_ids.COUNT>0) THEN
    FOR Idx1 IN g_alc_ledger_ids.FIRST .. g_alc_ledger_ids.LAST LOOP
      l_count:=l_count+1;
      g_array_ledger_attrs.array_ledger_id(l_count) := g_alc_ledger_ids(Idx1);
      g_array_ledger_attrs.array_ledger_currency_code(l_count):=
                     xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_CURRENCY_CODE'
                         , p_target_ledger_id   => g_alc_ledger_ids(Idx1));
      g_array_ledger_attrs.array_mau(l_count):=
                     xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_CURRENCY_MAU'
                         , p_target_ledger_id   => g_alc_ledger_ids(Idx1)
                         );
      g_array_ledger_attrs.array_rounding_rule_code(l_count):= l_pri_rounding_rule_code;
      g_array_ledger_attrs.array_rounding_offset(l_count) := l_pri_rounding_offset;
      g_array_ledger_attrs.array_ledger_type(l_count) := 'ALC';
      g_array_ledger_attrs.array_default_rate_type(l_count) :=
                          xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_DEFAULT_CONV_RATE_TYPE'
                         , p_target_ledger_id   => g_alc_ledger_ids(Idx1)
                         );
      g_array_ledger_attrs.array_inhert_type_flag(l_count) :=
                          xla_accounting_cache_pkg.GetValueChar(
                           p_source_code        => 'XLA_INHERIT_CONVERSION_TYPE'
                         , p_target_ledger_id   => g_alc_ledger_ids(Idx1)
                         );
      g_array_ledger_attrs.array_max_roll_date(l_count) :=
                          xla_accounting_cache_pkg.GetValueNum(
                           p_source_code        => 'XLA_MAX_DAYS_ROLL_RATE'
                         , p_target_ledger_id   => g_alc_ledger_ids(Idx1)
                         );
    END LOOP;
  END IF;

  p_array_ledger_attrs := g_array_ledger_attrs;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Count of ledgers returned = '||
                         to_char(l_count)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function BuildLedgerArray'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END BuildLedgerArray;

PROCEDURE GetLedgerArray
( p_array_ledger_attrs OUT NOCOPY t_array_ledger_attrs)
IS
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLedgerArray';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GETLEDGERARRAY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Count of ledgers returned = '||
                         TO_CHAR(g_array_ledger_attrs.array_ledger_id.COUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of function GETLEDGERARRAY'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

  p_array_ledger_attrs := g_array_ledger_attrs;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetLedgerArray;

FUNCTION GetCurrencyMau(p_currency_code IN VARCHAR2) return NUMBER
IS
l_entered_currency_mau              t_record_currency_mau;
l_log_module                VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.GetCurrencyMau';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'BEGIN of procedure GetCurrencyMau'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  IF(g_entered_currency_mau.currency_code is null or g_entered_currency_mau.currency_code <> p_currency_code) THEN
    IF(g_entered_currency_mau1.currency_code is not null and g_entered_currency_mau1.currency_code = p_currency_code) THEN
      l_entered_currency_mau := g_entered_currency_mau1;
      g_entered_currency_mau1 := g_entered_currency_mau;
      g_entered_currency_mau := l_entered_currency_mau;
    ELSIF(g_entered_currency_mau2.currency_code is not null and g_entered_currency_mau2.currency_code = p_currency_code) THEN
      l_entered_currency_mau := g_entered_currency_mau2;
      g_entered_currency_mau2 := g_entered_currency_mau;
      g_entered_currency_mau := l_entered_currency_mau;
    ELSE
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
          (p_msg      => 'get from the db'
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
      END IF;

      SELECT nvl(minimum_accountable_unit, power(10, -1* precision))
        INTO l_entered_currency_mau.currency_mau
        FROM FND_CURRENCIES
       WHERE currency_code = p_currency_code;

      l_entered_currency_mau.currency_code := p_currency_code;
      g_entered_currency_mau2 := g_entered_currency_mau1;
      g_entered_currency_mau1 := g_entered_currency_mau;
      g_entered_currency_mau  := l_entered_currency_mau;
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'END of procedure GetCurrencyMau:'||to_char(g_entered_currency_mau.currency_mau)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  return g_entered_currency_mau.currency_mau;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END GetCurrencyMau;

--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

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
-- Following code is executed when the package body is referenced for the first
-- time
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

BEGIN
--   l_log_module     := C_DEFAULT_MODULE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END xla_accounting_cache_pkg;

/
