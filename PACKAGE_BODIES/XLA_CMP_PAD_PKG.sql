--------------------------------------------------------
--  DDL for Package Body XLA_CMP_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_PAD_PKG" AS
/* $Header: xlacppad.pkb 120.30 2006/08/23 18:26:46 wychan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_pad_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for package body generation                                            |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     18-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     07-MAI-2003 K.Boussema    Added the extract of the PAD version         |
|     26-MAI-2003 K.Boussema    Added the lock of PAD                        |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2729143                  |
|     17-JUL-2003 K.Boussema    Reviewed the code                            |
|     01-SEP-2003 K.Boussema    Reviewed the package comment generated       |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-DEC-2003 K.Boussema    Added a call to Extract Integrity checker    |
|     19-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                               trace() procedure                            |
|     20-Sep-2004 S.Singhania   Made ffg changes for the bulk performance:   |
|                                 - Modified constants C_PACKAGE_SPEC,       |
|                                   C_PACKAGE_BODY_1, C_PACKAGE_BODY_2,      |
|                                   C_PRIVATE_API_1.                         |
|                                 - Obsoleted the routines GetPackageName,   |
|                                   InitGlobalVariables                      |
|                                 - Modified the routines GenerateBodyPackage|
|                                   ,GeneratePrivateProcedures, GenerateBody,|
|                                   CreateBodyPackage, Compile               |
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     11-Jul-2005 A.Wan         Changed for MPA 4262811                      |
+===========================================================================*/

--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                    AAD templates/Global constants                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--

C_COMMENT  CONSTANT VARCHAR2(2000) :=
'/'||'*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     $name
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From Product Accounting Definition              |
|     $pad_name$
|     $pad_code$
|     $pad_owner$
|     $pad_version$
|     $pad_context$
| HISTORY                                                               |
|     $history
+=======================================================================*'||'/'
 ;



--+==========================================================================+
--|            specifcation  package template                                |
--+==========================================================================+

--
C_PACKAGE_SPEC  CONSTANT  VARCHAR2(10000) :=
--
'CREATE OR REPLACE PACKAGE $PACKAGE_NAME$ AS
--
$header$
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
;

FUNCTION CreateJournalEntries(
        p_application_id         IN NUMBER
      , p_base_ledger_id         IN NUMBER
      , p_pad_start_date         IN DATE
      , p_pad_end_date           IN DATE
      , p_primary_ledger_id      IN NUMBER)
RETURN NUMBER;
--
--
END $PACKAGE_NAME$;
--
';
--


--+==========================================================================+
--|   Template Body package associated to a Product Accounting definition    |
--+==========================================================================+
--
C_PACKAGE_BODY_1   CONSTANT VARCHAR2(10000) := '
--
CREATE OR REPLACE PACKAGE BODY $PACKAGE_NAME$ AS
--
$header$
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := ''xla.plsql.$PACKAGE_NAME$'';

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
             (p_location   => ''$PACKAGE_NAME$.trace'');
END trace;

--
--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+
--
'
;

C_PRIVATE_API_1   CONSTANT VARCHAR2(32000) := '
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
      l_log_module := C_DEFAULT_MODULE||''.ValidateLookupMeaning'';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''BEGIN of ValidateLookupMeaning''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => ''p_source_code = ''|| p_source_code||
                        '' - p_source_type_code = ''|| p_source_type_code||
                        '' - p_source_application_id = ''|| p_source_application_id||
                        '' - p_lookup_code = ''|| p_lookup_code||
                        '' - p_lookup_type = ''|| p_lookup_type||
                        '' - p_meaning = ''|| p_meaning
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_lookup_code IS NOT NULL AND p_meaning IS NULL THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg. build_message
               (p_appli_s_name            => ''XLA''
               ,p_msg_name                => ''XLA_AP_NO_LOOKUP_MEANING''
               ,p_token_1                 => ''SOURCE_NAME''
               ,p_value_1                 =>  xla_ae_sources_pkg.GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
               ,p_token_2                 => ''LOOKUP_CODE''
               ,p_value_2                 =>  p_lookup_code
               ,p_token_3                 => ''LOOKUP_TYPE''
               ,p_value_3                 =>  p_lookup_type
               ,p_token_4                 => ''PRODUCT_NAME''
               ,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
               ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
               ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
               ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
       );

   IF (C_LEVEL_ERROR >= g_log_level) THEN
           trace
                (p_msg      => ''ERROR: XLA_AP_NO_LOOKUP_MEANING''
                ,p_level    => C_LEVEL_ERROR
                ,p_module   => l_log_module);
   END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
          (p_msg      => ''END of ValidateLookupMeaning''
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;
RETURN p_meaning;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RETURN p_meaning;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => ''$PACKAGE_NAME$.ValidateLookupMeaning'');
       --
END ValidateLookupMeaning;
--
--
';
--
--
--
C_PACKAGE_BODY_2   CONSTANT VARCHAR2(32000) := '
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
   l_log_module := C_DEFAULT_MODULE||''.CreateJournalEntries'';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => ''BEGIN of CreateJournalEntries''||
                     '' - p_base_ledger_id = ''||TO_CHAR(p_base_ledger_id)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);

END IF;

--
g_diagnostics_mode:= xla_accounting_engine_pkg.g_diagnostics_mode;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => ''g_diagnostics_mode = ''||g_diagnostics_mode
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
xla_ae_journal_entry_pkg.SetProductAcctDefinition
   (p_product_rule_code      => ''$PRODUCT_RULE_CODE$''
   ,p_product_rule_type_code => ''$PRODUCT_RULE_TYPE_CODE$''
   ,p_product_rule_version   => ''$PRODUCT_RULE_VERSION$''
   ,p_product_rule_name      => ''$PRODUCT_RULE_NAME$''
   ,p_amb_context_code       => ''$AMB_CONTEXT_CODE$''
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


IF (g_diagnostics_mode = ''Y'' AND
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
      (p_msg      => ''return value. = ''||TO_CHAR(l_result)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => ''END of CreateJournalEntries ''
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => ''ERROR. = ''||sqlerrm
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => ''ERROR. = ''||sqlerrm
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => ''$PACKAGE_NAME$.CreateJournalEntries'');
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
END $PACKAGE_NAME$;
--
';
--
--
--
--+==========================================================================+
--|                                                                          |
--| Private global variable                                                  |
--|                                                                          |
--+==========================================================================+
--
g_UserName                      VARCHAR2(100);
g_PackageName                   VARCHAR2(30);
g_ProductRuleName               VARCHAR2(80);
g_ProductRuleVersion            VARCHAR2(30);

--+==========================================================================+
--|                                                                          |
--| Private global constant or variable declarations                         |
--|                                                                          |
--+==========================================================================+
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_pad_pkg';

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
             (p_location   => 'xla_cmp_pad_pkg.trace');
END trace;
--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+

--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

/*-------------------------------------------------------------+
|                                                              |
|  Private function                                            |
|                                                              |
|  return the application name                                 |
|                                                              |
+-------------------------------------------------------------*/

FUNCTION GetApplicationName (p_application_id   IN NUMBER)
RETURN VARCHAR2
IS
l_application_name          VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetApplicationName';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetApplicationName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

  SELECT  REPLACE(fat.application_name, '''','''''')
    INTO  l_application_name
    FROM  fnd_application_tl fat
   WHERE  fat.application_id = p_application_id
     AND  fat.language = nvl(USERENV('LANG'),fat.language)
     ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetApplicationName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_application_name;
EXCEPTION
 WHEN OTHERS THEN
    RETURN TO_CHAR(p_application_id);
END GetApplicationName;

/*------------------------------------------------+
|                                                 |
|  Private function                               |
|                                                 |
|  return the user name                           |
|                                                 |
+------------------------------------------------*/

FUNCTION GetUserName
RETURN VARCHAR2
IS
--
 l_user_name                  VARCHAR2(100);
 l_log_module         VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetUserName';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetUserName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

xla_environment_pkg.refresh;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Select from fnd_user'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

     SELECT  nvl(fd.user_name, 'ANONYMOUS')
       INTO  l_user_name
       FROM  fnd_user fd
      WHERE  fd.user_id = xla_environment_pkg.g_Usr_Id
     ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'User name = ' || l_user_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of GetUserName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_user_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_user_name := 'ANONYMOUS';
        RETURN l_user_name;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_pad_pkg.GetUserName');
END GetUserName;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|  return the Application Accounting Definition name            |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GetPADName      (   p_application_id            IN NUMBER
                           , p_product_rule_code         IN VARCHAR2
                           , p_product_rule_type_code    IN VARCHAR2
                           , p_product_rule_version      IN VARCHAR2
                           , p_amb_context_code          IN VARCHAR2
                          )
RETURN VARCHAR2
IS
l_product_rule_name          VARCHAR2(80);
l_log_module                 VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetPADName';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetPADName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

     SELECT nvl(xprt.name, p_product_rule_code)
          , nvl(p_product_rule_version,xprb.product_rule_version)
      INTO  l_product_rule_name
          , g_ProductRuleVersion
      FROM  xla_product_rules_tl xprt
          , xla_product_rules_b  xprb
     WHERE  xprb.application_id                  = p_application_id
        AND xprb.product_rule_code               = p_product_rule_code
        AND xprb.product_rule_type_code          = p_product_rule_type_code
        AND xprb.application_id                  = xprt.application_id (+)
        AND xprb.product_rule_code               = xprt.product_rule_code (+)
        AND xprb.product_rule_type_code          = xprt.product_rule_type_code (+)
        AND xprb.amb_context_code                = xprt.amb_context_code (+)
        AND xprb.amb_context_code                = p_amb_context_code
        AND xprb.enabled_flag                    ='Y'
        AND xprt.language(+)                     = USERENV('LANG')
      ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'product_rule_name = ' || l_product_rule_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of GetUserName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_product_rule_name ;
EXCEPTION
   WHEN NO_DATA_FOUND  OR TOO_MANY_ROWS THEN
      RETURN p_product_rule_code;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN p_product_rule_code;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_pad_pkg.GetPADName');
END GetPADName;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|  Create the comment in the AAD packages                       |
|                                                               |
+--------------------------------------------------------------*/
FUNCTION InsertString(  p_InputString   IN VARCHAR2
                      , p_token         IN VARCHAR2
                      , p_value         IN VARCHAR2)
RETURN VARCHAR2
IS
  l_OutputString      VARCHAR2(2000);
BEGIN
   --
   l_OutputString := REPLACE(p_InputString,p_token,p_value);
   l_OutputString := SUBSTR(l_OutputString,1,66);
   l_OutputString := l_Outputstring  || LPAD('|', 67- LENGTH(l_OutputString));
   --
   return l_OutputString ;
END InsertString;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|      GeneratePkgComment                                       |
|                                                               |
|  Create the comment in the AAD packages                       |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GeneratePkgComment ( p_user_name              IN VARCHAR2
                            , p_package_name           IN VARCHAR2
                            , p_product_rule_code      IN VARCHAR2
                            , p_product_rule_type_code IN VARCHAR2
                            , p_product_rule_name      IN VARCHAR2
                            , p_product_rule_version   IN VARCHAR2
                            , p_amb_context_code       IN VARCHAR2
                            )
RETURN VARCHAR2
IS

l_header                 VARCHAR2(32000);
l_StringValue            VARCHAR2(2000);
l_log_module             VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GeneratePkgComment';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GeneratePkgComment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_user_name = '||p_user_name||
                       ' - p_package_name = '||p_package_name||
                       ' - p_product_rule_code = '||p_product_rule_code||
                       ' - p_product_rule_type_code = '||p_product_rule_type_code||
                       ' - p_product_rule_name = '||p_product_rule_name||
                       ' - p_product_rule_version = '||p_product_rule_version||
                       ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_header := C_COMMENT;

l_StringValue   := InsertString( p_InputString => '$pkg_name'
                                ,p_token       => '$pkg_name'
                                ,p_value       =>  p_package_name
                               );

l_header := REPLACE(l_header,'$name',l_StringValue);

l_StringValue := InsertString(p_InputString => ' Name    : $name '
                        ,p_token       => '$name'
                        ,p_value       =>  p_product_rule_name
                        );

l_header := REPLACE(l_header,'$pad_name$',l_StringValue);

IF p_product_rule_code IS NOT NULL THEN
 --
   l_StringValue     := InsertString(p_InputString => ' Code    : $code'
                                    ,p_token       => '$code'
                                    ,p_value       => p_product_rule_code
                                   );
ELSE
   l_StringValue     := InsertString(p_InputString => ' Code    : $code'
                                   ,p_token       => '$code'
                                   ,p_value       => '  '
                                   );
END IF;
l_header := REPLACE(l_header,'$pad_code$',l_StringValue);

IF p_product_rule_type_code IS NOT NULL AND p_product_rule_type_code = 'S' THEN
 --
   l_StringValue     := InsertString(p_InputString => ' Owner   : $owner'
                                    ,p_token       => '$owner'
                                    ,p_value       => 'PRODUCT'
                                   );
ELSIF p_product_rule_type_code IS NOT NULL AND p_product_rule_type_code = 'C' THEN

   l_StringValue     := InsertString(p_InputString => ' Owner   : $owner'
                                    ,p_token       => '$owner'
                                    ,p_value       => 'CUSTOMER'
                                   );
ELSE
   l_StringValue     := InsertString(p_InputString => ' Owner   : $owner'
                                   ,p_token       => '$owner'
                                   ,p_value       => '  '
                                   );
END IF;
l_header := REPLACE(l_header,'$pad_owner$',l_StringValue);
--
-- insert PAD context
--
IF p_amb_context_code IS NOT NULL THEN
 --
   l_StringValue     := InsertString(p_InputString => ' AMB Context Code: $context'
                                    ,p_token       => '$context'
                                    ,p_value       => p_amb_context_code
                                   );
ELSE
  l_StringValue     := InsertString(p_InputString => ' AMB Context Code : $context'
                                   ,p_token       => '$context'
                                   ,p_value       => '  '
                                   );
END IF;
l_header := REPLACE(l_header,'$pad_context$',l_StringValue);
--
--
IF g_ProductRuleVersion IS NOT NULL THEN
 --
   l_StringValue     := InsertString(p_InputString => ' Version : $version'
                                    ,p_token       => '$version'
                                    ,p_value       => g_ProductRuleVersion
                                   );
ELSE
  l_StringValue     := InsertString(p_InputString => ' Version : $version'
                                   ,p_token       => '$version'
                                   ,p_value       => '  '
                                   );
END IF;
l_header := REPLACE(l_header,'$pad_version$',l_StringValue);

l_StringValue   := REPLACE('Generated at $date by user $user ' ,'$date',
                          TO_CHAR(sysdate, 'DD-MM-YYYY "at" HH:MM:SS' ));

l_StringValue   := InsertString(p_InputString => l_StringValue
                               ,p_token       => '$user'
                               ,p_value       => p_user_name
                              );
l_header := REPLACE(l_header,'$history',l_StringValue );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GeneratePkgComment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_header;
EXCEPTION
   WHEN OTHERS THEN
        RETURN NULL;
END GeneratePkgComment;


/*--------------------------------------------------------------+
|                                                               |
|                                                               |
|                                                               |
|       Generation of AAD specification packages                |
|                                                               |
|                                                               |
|                                                               |
+--------------------------------------------------------------*/


/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     BuildSpecPkg                                              |
|                                                               |
|  Creates the AAD specification packages                       |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION BuildSpecPkg(   p_user_name              IN VARCHAR2
                       , p_package_name           IN VARCHAR2
                       , p_product_rule_code      IN VARCHAR2
                       , p_product_rule_type_code IN VARCHAR2
                       , p_product_rule_name      IN VARCHAR2
                       , p_product_rule_version   IN VARCHAR2
                       , p_amb_context_code       IN VARCHAR2)
RETURN VARCHAR2
IS
l_SpecPkg            VARCHAR2(32000);
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.BuildSpecPkg';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of BuildSpecPkg'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_user_name = '||p_user_name||
                       ' - p_package_name = '||p_package_name||
                       ' - p_product_rule_code = '||p_product_rule_code||
                       ' - p_product_rule_type_code = '||p_product_rule_type_code||
                       ' - p_product_rule_name = '||p_product_rule_name||
                       ' - p_product_rule_version = '||p_product_rule_version||
                       ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_SpecPkg   := C_PACKAGE_SPEC;

l_SpecPkg   := REPLACE(l_SpecPkg,'$PACKAGE_NAME$',p_package_name);

l_SpecPkg   := REPLACE(l_SpecPkg,'$header$',GeneratePkgComment (
                                  p_user_name               => p_user_name
                                , p_package_name            => p_package_name
                                , p_product_rule_code       => p_product_rule_code
                                , p_product_rule_type_code  => p_product_rule_type_code
                                , p_product_rule_name       => p_product_rule_name
                                , p_product_rule_version    => p_product_rule_version
                                , p_amb_context_code        => p_amb_context_code
                             ) );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of BuildSpecPkg = '||length(l_SpecPkg)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_SpecPkg ;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception   THEN
       RETURN NULL;
  WHEN OTHERS    THEN
       xla_exceptions_pkg.raise_message
            (p_location => 'xla_cmp_pad_pkg.BuildSpecPkg');
END BuildSpecPkg;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateSpecPackage                                       |
|                                                               |
| Generates the AAD specifcation packages from AAD definitions  |
| Returns TRUE if the compiler succeeds to generate the spec.   |
| package, FALSE otherwise.                                     |
+--------------------------------------------------------------*/

FUNCTION GenerateSpecPackage(
  p_application_id               IN NUMBER
, p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_product_rule_version         IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_package                     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateSpecPackage';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      =>' p_product_rule_code = '||p_product_rule_code||
                       ' - p_product_rule_type_code = '||p_product_rule_type_code||
                       ' - p_application_id = '||p_application_id||
                       ' - p_product_rule_version = '||p_product_rule_version||
                       ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

p_package  := BuildSpecPkg(
               p_user_name               => g_UserName
             , p_package_name            => g_PackageName
             , p_product_rule_code       => p_product_rule_code
             , p_product_rule_type_code  => p_product_rule_type_code
             , p_product_rule_name       => g_ProductRuleName
             , p_product_rule_version    => p_product_rule_version
             , p_amb_context_code        => p_amb_context_code
              );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN (p_package IS NOT NULL);
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception   THEN
       RETURN FALSE;
  WHEN OTHERS    THEN
       xla_exceptions_pkg.raise_message
            (p_location => 'xla_cmp_pad_pkg.GenerateSpecPackage');
END GenerateSpecPackage;

/*------------------------------------------------------------------+
|                                                                   |
|  Private function                                                 |
|                                                                   |
|     CreateSpecPackage                                             |
|                                                                   |
| Creates/compiler the AAD specification packages in the DATABASE   |
| It returns TRUE, if the package created is VALID, FALSE otherwise |
|                                                                   |
+------------------------------------------------------------------*/

FUNCTION CreateSpecPackage (
                       p_application_id           IN NUMBER
                     , p_product_rule_code        IN VARCHAR2
                     , p_product_rule_type_code   IN VARCHAR2
                     , p_product_rule_version     IN VARCHAR2
                     , p_amb_context_code         IN VARCHAR2)
RETURN BOOLEAN
IS
l_Package             VARCHAR2(32000);
l_IsCompiled          BOOLEAN;
l_log_module          VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateSpecPackage';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of CreateSpecPackage'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_IsCompiled  := GenerateSpecPackage(
  p_application_id               => p_application_id
, p_product_rule_code            => p_product_rule_code
, p_product_rule_type_code       => p_product_rule_type_code
, p_product_rule_version         => p_product_rule_version
, p_amb_context_code             => p_amb_context_code
, p_package                      => l_Package
);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      =>' Compile the specification package in the DATABASE'||
                       ' - length of the package = '||length(l_Package)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_IsCompiled  := xla_cmp_create_pkg.CreateSpecPackage(
                      p_product_rule_name  =>  g_ProductRuleName
                    , p_package_name       =>  g_PackageName
                    , p_package_text       =>  l_Package
                    )
                AND l_IsCompiled;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CreateSpecPackage : return = '
                        ||CASE WHEN l_IsCompiled THEN 'TRUE' ELSE 'FALSE' END
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_IsCompiled;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN FALSE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_pad_pkg.CreateSpecPackage');
END CreateSpecPackage;

/*--------------------------------------------------------------+
|                                                               |
|                                                               |
|                                                               |
|                Generation of AAD Body packages                |
|                                                               |
|                                                               |
|                                                               |
+--------------------------------------------------------------*/

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GeneratePrivateProcedures                                 |
|                                                               |
|  Generates private procedures and functions in AAD packages   |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GeneratePrivateProcedures
       (p_application_id               IN NUMBER
       ,p_product_rule_code            IN VARCHAR2
       ,p_product_rule_type_code       IN VARCHAR2
       ,p_product_rule_name            IN VARCHAR2
       ,p_product_rule_version         IN VARCHAR2
       ,p_amb_context_code             IN VARCHAR2
       ,p_package_name                 IN VARCHAR2
       --
       ,p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
       ,p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
       ,p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS
--
l_IsCompiled            BOOLEAN;
l_IsGenerated           BOOLEAN;
--
l_array_body            DBMS_SQL.VARCHAR2S;
l_array_string          DBMS_SQL.VARCHAR2S;
l_log_module            VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.GeneratePrivateProcedures';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of GeneratePrivateProcedures'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
l_IsCompiled         := TRUE;
l_IsGenerated        := TRUE;

-- generate description functions and the call to those functions
l_array_body    := xla_cmp_string_pkg.g_null_varchar2s;
l_array_string  := xla_cmp_string_pkg.g_null_varchar2s;

--
-- Generate Descriptions
--

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL XLA_CMP_DESCRIPTION_PKG.GenerateDescriptions API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;

l_IsGenerated     :=
   XLA_CMP_DESCRIPTION_PKG.GenerateDescriptions
      (p_product_rule_code         => p_product_rule_code
      ,p_product_rule_type_code    => p_product_rule_type_code
      ,p_application_id            => p_application_id
      ,p_amb_context_code          => p_amb_context_code
      ,p_package_name              => p_package_name
      --
      ,p_rec_aad_objects           => p_rec_aad_objects
      ,p_rec_sources               => p_rec_sources
      --
      ,p_package_body              => l_array_string);

l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;
--
l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);
--
l_array_string := xla_cmp_string_pkg.g_null_varchar2s;

-- generate account derivation rule functions
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL XLA_CMP_ADR_PKG.GenerateADR API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
l_IsGenerated   :=
   xla_cmp_adr_pkg.GenerateADR
      (p_product_rule_code         => p_product_rule_code
      ,p_product_rule_type_code    => p_product_rule_type_code
      ,p_application_id            => p_application_id
      ,p_amb_context_code          => p_amb_context_code
      ,p_package_name              => p_package_name
      --
      ,p_rec_aad_objects           => p_rec_aad_objects
      ,p_rec_sources               => p_rec_sources
      ,p_package_body              => l_array_string);

l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);
--
l_array_string := xla_cmp_string_pkg.g_null_varchar2s;
--
l_IsCompiled   := l_IsCompiled AND l_IsGenerated;

--------------------------------------------------------------------------------------
-- 4262811  Generate Recognition JLT for MPA
--------------------------------------------------------------------------------------
l_IsGenerated := XLA_CMP_MPA_JLT_PKG.GenerateMpaJLT
      (p_product_rule_code            => p_product_rule_code
      ,p_product_rule_type_code       => p_product_rule_type_code
      ,p_application_id               => p_application_id
      ,p_amb_context_code             => p_amb_context_code
      ,p_package_name                 => p_package_name
      ,p_rec_aad_objects              => p_rec_aad_objects
      ,p_rec_sources                  => p_rec_sources
      ,p_package_body                 => l_array_string);

l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);
--
l_array_string := xla_cmp_string_pkg.g_null_varchar2s;
--
l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;
--------------------------------------------------------------------------------------

-- generate accounting line type procedures
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL xla_cmp_acct_line_type_pkg.GenerateAcctLineType API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
l_IsGenerated  :=
   xla_cmp_acct_line_type_pkg.GenerateAcctLineType
      (p_product_rule_code         => p_product_rule_code
      ,p_product_rule_type_code    => p_product_rule_type_code
      ,p_application_id            => p_application_id
      ,p_amb_context_code          => p_amb_context_code
      ,p_package_name              => p_package_name
      --
      ,p_rec_aad_objects           => p_rec_aad_objects
      ,p_rec_sources               => p_rec_sources
      ,p_package_body              => l_array_string);

l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);
--
l_array_string := xla_cmp_string_pkg.g_null_varchar2s;
--
l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

-- generate Event Class and Procedure
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL xla_cmp_event_type_pkg.GenerateEventClassAndType API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;

l_IsGenerated  :=
   xla_cmp_event_type_pkg.GenerateEventClassAndType
      (p_application_id              => p_application_id
      ,p_product_rule_code           => p_product_rule_code
      ,p_product_rule_type_code      => p_product_rule_type_code
      ,p_product_rule_version        => p_product_rule_version
      ,p_amb_context_code            => p_amb_context_code
      ,p_product_rule_name           => p_product_rule_name
      ,p_package_name                => p_package_name
      --
      ,p_rec_aad_objects             => p_rec_aad_objects
      ,p_rec_sources                 => p_rec_sources
      --
      ,p_package_body                => l_array_string);

l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);
--
l_array_string := xla_cmp_string_pkg.g_null_varchar2s;

l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;
--
-- generate get_meaning API for source associated to value set.
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL xla_cmp_source_pkg.GenerateGetMeaningAPI API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--

   l_IsGenerated     :=
      xla_cmp_source_pkg.GenerateGetMeaningAPI
         (p_package_name              => p_package_name
         ,p_array_flex_value_set_id   => p_rec_sources.array_flex_value_set_id
         ,p_package_body              => l_array_string);

   l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

   l_array_body   :=
      xla_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1    => l_array_string
         ,p_array_string_2    => l_array_body);

   l_array_string := xla_cmp_string_pkg.g_null_varchar2s;

   l_IsCompiled  := l_IsCompiled AND l_IsGenerated ;

-- generate main procedure
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '-> CALL xla_cmp_event_type_pkg.BuildMainProc API'
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
l_IsGenerated     :=
   xla_cmp_event_type_pkg.BuildMainProc
      (p_application_id            => p_application_id
      ,p_product_rule_code         => p_product_rule_code
      ,p_product_rule_type_code    => p_product_rule_type_code
      ,p_product_rule_name         => p_product_rule_name
      ,p_product_rule_version      => p_product_rule_version
      ,p_amb_context_code          => p_amb_context_code
      ,p_package_name              => p_package_name
      --
      ,p_rec_aad_objects           => p_rec_aad_objects
      --
      ,p_package_body              => l_array_string);

l_IsCompiled   := l_IsCompiled AND l_IsGenerated ;

l_array_body   :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1    => l_array_body
      ,p_array_string_2    => l_array_string);


l_array_string := xla_cmp_string_pkg.g_null_varchar2s;

p_package_body := l_array_body;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
             (p_msg      => 'l_isCompiled = '||CASE WHEN l_IsCompiled
                                                THEN 'TRUE'
                                                ELSE 'FALSE' END
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of GeneratePrivateProcedures'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_IsCompiled;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
        trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      END IF;
      RETURN FALSE;
  WHEN OTHERS    THEN
       xla_exceptions_pkg.raise_message
            (p_location => 'xla_cmp_pad_pkg.GeneratePrivateProcedures');
END GeneratePrivateProcedures;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateBody                                              |
|                                                               |
|  Generates the procedures and functions in AAD body packages  |
|                                                               |
+--------------------------------------------------------------*/

FUNCTION GenerateBody
       (p_application_id               IN NUMBER
       ,p_product_rule_code            IN VARCHAR2
       ,p_product_rule_type_code       IN VARCHAR2
       ,p_product_rule_name            IN VARCHAR2
       ,p_product_rule_version         IN VARCHAR2
       ,p_amb_context_code             IN VARCHAR2
       ,p_package_name                 IN VARCHAR2
       ,p_package_body                OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS
--
l_rec_aad_objects                   xla_cmp_source_pkg.t_rec_aad_objects;
l_rec_sources                       xla_cmp_source_pkg.t_rec_sources;
l_null_rec_aad_objects              xla_cmp_source_pkg.t_rec_aad_objects;
l_null_rec_sources                  xla_cmp_source_pkg.t_rec_sources;
--
l_IsCompiled                        BOOLEAN;
l_log_module                        VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.GenerateBody';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of GenerateBody'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_application_id = '||p_application_id||
                       ' - p_product_rule_code = '||p_product_rule_code||
                       ' - p_product_rule_type_code = '||p_product_rule_type_code||
                       ' - p_product_rule_name = '||p_product_rule_name||
                       ' - p_product_rule_version = '||p_product_rule_version||
                       ' - p_package_name = '||p_package_name||
                       ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_IsCompiled     :=
   GeneratePrivateProcedures
      (p_application_id              => p_application_id
      ,p_product_rule_code           => p_product_rule_code
      ,p_product_rule_type_code      => p_product_rule_type_code
      ,p_product_rule_name           => p_product_rule_name
      ,p_product_rule_version        => p_product_rule_version
      ,p_amb_context_code            => p_amb_context_code
      ,p_package_name                => p_package_name
      ,p_rec_aad_objects             => l_rec_aad_objects
      ,p_rec_sources                 => l_rec_sources
      ,p_package_body                => p_package_body);

l_rec_aad_objects                :=  l_null_rec_aad_objects;
l_rec_sources                    :=  l_null_rec_sources;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
             (p_msg      => 'l_isCompiled = '||CASE WHEN l_IsCompiled
                                                THEN 'TRUE'
                                                ELSE 'FALSE' END
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of GenerateBody'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
RETURN l_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
        trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN FALSE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_pad_pkg.GenerateBody');
END GenerateBody;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|     GenerateSpecPackage                                       |
|                                                               |
| Generates the AAD body packages from AAD definitions          |
| Returns TRUE if the compiler succeeds to generate the body    |
| package, FALSE otherwise.                                     |
+--------------------------------------------------------------*/

FUNCTION GenerateBodyPackage
       (p_application_id               IN NUMBER
       ,p_product_rule_code            IN VARCHAR2
       ,p_product_rule_type_code       IN VARCHAR2
       ,p_product_rule_version         IN VARCHAR2
       ,p_amb_context_code             IN VARCHAR2
       ,p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S)
RETURN BOOLEAN IS

l_array_pkg              DBMS_SQL.VARCHAR2S;
l_BodyPkg                VARCHAR2(32000);
l_array_body             DBMS_SQL.VARCHAR2S;
l_IsCompiled             BOOLEAN;
l_log_module             VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.GenerateBodyPackage';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of GenerateBodyPackage'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_application_id = '||p_application_id||
                       ' - p_product_rule_code = '||p_product_rule_code||
                       ' - p_product_rule_type_code = '||p_product_rule_type_code||
                       ' - p_product_rule_version = '||p_product_rule_version||
                       ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_IsCompiled    := TRUE;
l_array_body    := xla_cmp_string_pkg.g_null_varchar2s;
l_array_pkg     := xla_cmp_string_pkg.g_null_varchar2s;

l_BodyPkg   := C_PACKAGE_BODY_1 || C_PRIVATE_API_1;
l_BodyPkg   := REPLACE(l_BodyPkg,'$PACKAGE_NAME$'   ,g_PackageName);

l_BodyPkg   :=
   REPLACE(l_BodyPkg,'$header$'
          ,GeneratePkgComment
             (p_user_name               => g_UserName
             ,p_package_name            => g_PackageName
             ,p_product_rule_code       => p_product_rule_code
             ,p_product_rule_type_code  => p_product_rule_type_code
             ,p_product_rule_name       => g_ProductRuleName
             ,p_product_rule_version    => p_product_rule_version
             ,p_amb_context_code        => p_amb_context_code)
          );

xla_cmp_string_pkg.CreateString
   (p_package_text  => l_BodyPkg
   ,p_array_string  => l_array_pkg);

l_IsCompiled :=
   GenerateBody
      (p_application_id           => p_application_id
      ,p_product_rule_code        => p_product_rule_code
      ,p_product_rule_type_code   => p_product_rule_type_code
      ,p_product_rule_name        => g_ProductRuleName
      ,p_product_rule_version     => p_product_rule_version
      ,p_amb_context_code         => p_amb_context_code
      ,p_package_name             => g_PackageName
      ,p_package_body             => l_array_body);

l_array_pkg :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1  =>  l_array_pkg
      ,p_array_string_2  =>  l_array_body);
--
-- create the PL/SQL DBMS_SQL.VARCHAR2S array
--
l_BodyPkg   := C_PACKAGE_BODY_2;
--
l_BodyPkg     := REPLACE(l_BodyPkg,'$PRODUCT_RULE_CODE$'     ,p_product_rule_code);
l_BodyPkg     := REPLACE(l_BodyPkg,'$PRODUCT_RULE_TYPE_CODE$',p_product_rule_type_code);
l_BodyPkg     := REPLACE(l_BodyPkg,'$PRODUCT_RULE_VERSION$'  ,g_ProductRuleVersion);
l_BodyPkg     := REPLACE(l_BodyPkg,'$PRODUCT_RULE_NAME$'     ,REPLACE(g_ProductRuleName,'''',''''''));
l_BodyPkg     := REPLACE(l_BodyPkg,'$PACKAGE_NAME$'          ,g_PackageName);
l_BodyPkg     := REPLACE(l_BodyPkg,'$AMB_CONTEXT_CODE$'      ,p_amb_context_code);

xla_cmp_string_pkg.CreateString
   (p_package_text  => l_BodyPkg
   ,p_array_string  => l_array_body);

l_array_pkg :=
   xla_cmp_string_pkg.ConcatTwoStrings
      (p_array_string_1  =>  l_array_pkg
      ,p_array_string_2  =>  l_array_body);

p_package_body      := l_array_pkg;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'return value (l_IsCompiled) = '||
        CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of GenerateBodyPackage'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
RETURN l_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RETURN FALSE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_pad_pkg.GenerateBodyPackage');
END GenerateBodyPackage;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|        CreateBodyPackage                                      |
|                                                               |
| Compiles the AAD body packages in the DATABASE                |
| Returns TRUE if the package body is VALID, FALSE otherwise.   |
|                                                               |
+--------------------------------------------------------------*/
FUNCTION CreateBodyPackage
       (p_application_id           IN NUMBER
       ,p_product_rule_code        IN VARCHAR2
       ,p_product_rule_type_code   IN VARCHAR2
       ,p_product_rule_version     IN VARCHAR2
       ,p_amb_context_code         IN VARCHAR2)
RETURN BOOLEAN IS
--
l_Package             DBMS_SQL.VARCHAR2S;
l_PackageName         VARCHAR2(30);
l_ProductRuleName     VARCHAR2(80);
l_ProductRuleVersion  VARCHAR2(30);
--
l_IsCompiled          BOOLEAN;
l_log_module          VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.CreateBodyPackage';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of CreateBodyPackage'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

l_IsCompiled  :=
   GenerateBodyPackage
      (p_application_id               => p_application_id
      ,p_product_rule_code            => p_product_rule_code
      ,p_product_rule_type_code       => p_product_rule_type_code
      ,p_product_rule_version         => p_product_rule_version
      ,p_amb_context_code             => p_amb_context_code
      ,p_package_body                 => l_Package);

  -- Store sources used by an AAD.

  DELETE xla_aad_sources
  WHERE  amb_context_code          = p_amb_context_code
  AND    product_rule_type_code    = p_product_rule_type_code
  AND    product_rule_code         = p_product_rule_code;

  INSERT INTO xla_aad_sources
      (
          APPLICATION_ID
         ,AMB_CONTEXT_CODE
         ,PRODUCT_RULE_TYPE_CODE
         ,PRODUCT_RULE_CODE
         ,ENTITY_CODE
         ,EVENT_CLASS_CODE
         ,SOURCE_CODE
         ,SOURCE_DATATYPE_CODE
         ,SOURCE_LEVEL_CODE
         ,EXTRACT_OBJECT_NAME
         ,EXTRACT_OBJECT_TYPE_CODE
         ,ALWAYS_POPULATED_FLAG
         ,COLUMN_DATATYPE_CODE
         ,SOURCE_HASH_ID
         ,SOURCE_APPLICATION_ID
         ,REFERENCE_OBJECT_FLAG
         ,JOIN_CONDITION
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,PROGRAM_UPDATE_DATE
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,REQUEST_ID
      )
   SELECT
          APPLICATION_ID
         ,p_amb_context_code
         ,p_product_rule_type_code
         ,p_product_rule_code
         ,ENTITY_CODE
         ,EVENT_CLASS_CODE
         ,SOURCE_CODE
         ,SOURCE_DATATYPE_CODE
         ,SOURCE_LEVEL_CODE
         ,EXTRACT_OBJECT_NAME
         ,EXTRACT_OBJECT_TYPE_CODE
         ,ALWAYS_POPULATED_FLAG
         ,COLUMN_DATATYPE_CODE
         ,SOURCE_HASH_ID
         ,SOURCE_APPLICATION_ID
         ,REFERENCE_OBJECT_FLAG
         ,JOIN_CONDITION
	 ,SYSDATE
	 ,xla_environment_pkg.g_usr_id
	 ,SYSDATE
	 ,xla_environment_pkg.g_usr_id
         ,xla_environment_pkg.g_login_id
         ,SYSDATE
         ,xla_environment_pkg.g_prog_appl_id
         ,xla_environment_pkg.g_prog_id
         ,xla_environment_pkg.g_Req_Id
   FROM xla_evt_class_sources_gt;

l_IsCompiled  :=
   xla_cmp_create_pkg.CreateBodyPackage
      (p_product_rule_name  =>  g_ProductRuleName
      ,p_package_name       =>  g_PackageName
      ,p_package_text       =>  l_Package)
   AND l_IsCompiled;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
      (p_msg      => 'return value (l_IsCompiled) = '||
        CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of CreateBodyPackage'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
RETURN l_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RETURN FALSE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_pad_pkg.CreateBodyPackage');
END CreateBodyPackage;

/*--------------------------------------------------------------+
|                                                               |
|  Private function                                             |
|                                                               |
|        CheckPackageCreation                                      |
|                                                               |
| Compiles the AAD body packages in the DATABASE                |
| Returns TRUE if the package body is VALID, FALSE otherwise.   |
|                                                               |
+--------------------------------------------------------------*/
PROCEDURE CheckPackageCreation
       (p_application_id           IN NUMBER
       ,p_product_rule_code        IN VARCHAR2
       ,p_product_rule_type_code   IN VARCHAR2
       ,p_amb_context_code         IN VARCHAR2
       ,x_standard_pkg_flag        IN OUT NOCOPY VARCHAR2
       ,x_bc_pkg_flag              IN OUT NOCOPY VARCHAR2)
IS
--
CURSOR c IS
  SELECT CASE WHEN SUM(DECODE(NVL(xld.budgetary_control_flag,'N'),'N',1,0)) > 0
              THEN 'Y'
              ELSE 'N' END
        ,CASE WHEN SUM(DECODE(NVL(xld.budgetary_control_flag,'N'),'Y',1,0)) > 0
              THEN 'Y'
              ELSE 'N' END
    FROM xla_aad_line_defn_assgns xald
       , xla_line_definitions_b   xld
   WHERE xld.application_id = xald.application_id
     AND xld.amb_context_code = xald.amb_context_code
     AND xld.event_class_code = xald.event_class_code
     AND xld.event_type_code  = xald.event_type_code
     AND xld.line_definition_owner_code = xald.line_definition_owner_code
     AND xld.line_definition_code = xald.line_definition_code
     AND xald.application_id = p_application_id
     AND xald.amb_context_code = p_amb_context_code
     AND xald.product_rule_type_code = p_product_rule_type_code
     AND xald.product_rule_code = p_product_rule_code;

l_log_module          VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.CheckPackageCreation';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of CheckPackageCreation'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

  OPEN c;
  FETCH c INTO x_standard_pkg_flag, x_bc_pkg_flag;
  CLOSE c;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'return value (x_standard_pkg_flag) = '||x_standard_pkg_flag
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'return value (x_bc_pkg_flag) = '||x_bc_pkg_flag
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of CheckPackageCreation'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RAISE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_pad_pkg.CheckPackageCreation');
END CheckPackageCreation;


--
--+==========================================================================+
--| PUBLIC function                                                          |
--|    Compile                                                               |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition.                                                |
--|                                                                          |
--| INPUT PARAMETERS                                                         |
--|                                                                          |
--| 1. p_application_id          : NUMBER, application identifier            |
--| 2. p_product_rule_code       : VARCHAR2(30), product definition code     |
--| 3. p_product_rule_type_code  : VARCHAR2(30), product definition type     |
--| 4. p_product_rule_version    : VARCHAR2(30), product definition Version  |
--|                                                                          |
--|  RETURNS                                                                 |
--|   1. l_IsCompiled  : BOOLEAN, TRUE if Product accounting definition has  |
--|                      been successfully created, FALSE otherwise.         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION Compile    (  p_application_id           IN NUMBER
                     , p_product_rule_code        IN VARCHAR2
                     , p_product_rule_type_code   IN VARCHAR2
                     , p_product_rule_version     IN VARCHAR2
                     , p_amb_context_code         IN VARCHAR2 )
RETURN BOOLEAN
IS
l_standard_pkg_flag   VARCHAR2(1);
l_bc_pkg_flag         VARCHAR2(1);
l_has_non_bc_jld      BOOLEAN;
l_IsCompiled          BOOLEAN;
l_IsLocked            BOOLEAN;
l_log_module          VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Compile';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of Compile'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id||
                        ' - p_product_rule_code = '||p_product_rule_code||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code||
                        ' - p_product_rule_version = '||p_product_rule_version||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

   g_ProductRuleVersion := p_product_rule_version;
   g_UserName           := GetUserName;

   g_ProductRuleName    :=
      GetPADName
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_product_rule_version    => g_ProductRuleVersion
         ,p_amb_context_code        => p_amb_context_code);

   g_PackageName        :=
      xla_cmp_hash_pkg.BuildPackageName
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_amb_context_code        => p_amb_context_code);

   g_component_name     := g_ProductRuleName;

   g_owner              :=
      xla_lookups_pkg.get_meaning
         (p_lookup_type    => 'XLA_OWNER_TYPE'
         ,p_lookup_code    => p_product_rule_type_code);

   g_component_appl     := GetApplicationName (p_application_id );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => 'g_ProductRuleVersion = '||g_ProductRuleVersion||
                         ' - g_UserName = '||g_UserName||
                         ' - g_ProductRuleName = '||g_ProductRuleName||
                         ' - g_PackageName = '||g_PackageName||
                         ' - g_component_name = '||g_component_name||
                         ' - g_owner = '||g_owner||
                         ' - g_component_appl = '||g_component_appl
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
   END IF;

 --
 -- Locking components of PAD in AMB datamodel
 --
   l_IsCompiled  :=
      xla_cmp_lock_pad_pkg.LockPAD
         (p_application_id         => p_application_id
         ,p_product_rule_code      => p_product_rule_code
         ,p_product_rule_type_code => p_product_rule_type_code
         ,p_product_rule_name      => g_ProductRuleName
         ,p_amb_context_code       => p_amb_context_code);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => ' AAD locked  = '||
           CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;

   CheckPackageCreation
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_amb_context_code        => p_amb_context_code
         ,x_standard_pkg_flag       => l_standard_pkg_flag
         ,x_bc_pkg_flag             => l_bc_pkg_flag);

   IF (l_standard_pkg_flag = 'Y') THEN
     g_bc_pkg_flag := 'N';
     l_IsCompiled  :=
        l_IsCompiled AND
        CreateSpecPackage
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_product_rule_version    => g_ProductRuleVersion
         ,p_amb_context_code        => p_amb_context_code);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => ' AAD specification package created  = '||
           CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
      END IF;

      l_IsCompiled  :=
         l_IsCompiled AND
         CreateBodyPackage
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_product_rule_version    => g_ProductRuleVersion
         ,p_amb_context_code        => p_amb_context_code);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => ' AAD body  package created  = '||
           CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
      END IF;
   END IF;

   IF (l_bc_pkg_flag = 'Y') THEN
      g_bc_pkg_flag := 'Y';
      g_PackageName := REPLACE(g_PackageName,'_PKG','_BC_PKG');
      DELETE FROM xla_evt_class_sources_gt;

      l_IsCompiled  :=
        l_IsCompiled AND
        CreateSpecPackage
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_product_rule_version    => g_ProductRuleVersion
         ,p_amb_context_code        => p_amb_context_code);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => ' AAD specification package created  = '||
           CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
      END IF;

      l_IsCompiled  :=
         l_IsCompiled AND
         CreateBodyPackage
         (p_application_id          => p_application_id
         ,p_product_rule_code       => p_product_rule_code
         ,p_product_rule_type_code  => p_product_rule_type_code
         ,p_product_rule_version    => g_ProductRuleVersion
         ,p_amb_context_code        => p_amb_context_code);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => ' AAD body  package created  = '||
           CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
      END IF;

   END IF;

   --
   -- bug 3417369
   --
   IF NOT l_IsCompiled THEN
      xla_amb_setup_err_pkg.stack_error
         (p_message_name              => 'XLA_CMP_TECHNICAL_ERROR'
         ,p_message_type              => 'E'
         ,p_message_category          => 'AAD'
         ,p_category_sequence         => 1
         ,p_application_id            => p_application_id
         ,p_amb_context_code          => p_amb_context_code
         ,p_product_rule_type_code    => p_product_rule_type_code
         ,p_product_rule_code         => p_product_rule_code);
   END IF;

   --============================================
   -- Integration of  Extract Integrity checker
   --============================================
   xla_amb_setup_err_pkg.insert_errors;
   --
   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'return value. = '||
             CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'END of Compile'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   RETURN l_IsCompiled;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
             trace
                 (p_msg      => '-> CALL xla_amb_setup_err_pkg.stack_error API '
                 ,p_level    => C_LEVEL_PROCEDURE
                 ,p_module   => l_log_module);
          END IF;

          xla_amb_setup_err_pkg.stack_error(
                               p_message_name              => 'XLA_CMP_TECHNICAL_ERROR'
                              ,p_message_type              => 'E'
                              ,p_message_category          => 'AAD'
                              ,p_category_sequence         => 1
                              ,p_application_id            => p_application_id
                              ,p_amb_context_code          => p_amb_context_code
                              ,p_product_rule_type_code    => p_product_rule_type_code
                              ,p_product_rule_code         => p_product_rule_code
                );
        --
        --============================================
        -- Integration of  Extract Integrity checker
        --============================================

        xla_amb_setup_err_pkg.insert_errors;
        --
        COMMIT;
        --
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_TECHNICAL_ERROR ='||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
        END IF;
        --
        RETURN FALSE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_pad_pkg.Compile');
END Compile;
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
END xla_cmp_pad_pkg; -- end of package spec

/
