--------------------------------------------------------
--  DDL for Package Body XLA_AE_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AE_SOURCES_PKG" AS
/* $Header: xlajescs.pkb 120.30.12010000.3 2010/01/31 14:52:23 vkasina ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_sources_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     13-MAI-2003 K.Boussema    Updated Code messages                        |
|     16-MAI-2003 K.Boussema    Changed to accept value NULL for some system |
|                               sources.                                     |
|     19-MAI-2003 K.Boussema    Modified GetTranslatedLookupMeaning          |
|                               GetUnTranslatedLookupMeaning                 |
|                               and get_flex_value_meaning                   |
|                               to fix BUG 2965699                           |
|     30-MAI-2003 K.Boussema    Reviewed get_flex_value_meaning, bug2975670  |
|     12-JUN-2003 K.Boussema    Reviewed GetSystemSource fcts, bug 2990642   |
|     23-JUN-2003 K.Boussema   Updated the call to get_period_name bug3005754|
|     30-JUN-2003 K.Boussema   Changed XLA_PERIOD_TYPES by XLA_PERIOD_TYPE   |
|     17-JUL-2003 K.Boussema    Updated the call to accounting cache, 3055039|
|     21-JUL-2003 K.Boussema   Changed the source name from                  |
|                              GL_COA_MAPPINGS_NAME to GL_COA_MAPPING_NAME   |
|                              Updated to trap NO_DATA_FOUND exception       |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     29-JUL-2003 K.Boussema   Included the retrieve of 'Legal entity name'  |
|     04-AUG-2003 S.Singhania  corrected a typo in the source code:          |
|                               XLA_ACCOUNTING_METHOD_NAME                   |
|     01-SEP-2003 K.Boussema   Removed XLA_LEGAL_ENTITY_NAME system source   |
|                              Add the update of JE status if system source  |
|                              invalid                                       |
|     19-SEP-2003 K.Boussema   Added new system source XLA_JE_CATEGORY_NAME  |
|     15-DEC-2003 K.Boussema   Removed get_flex_value_meaning function       |
|     18-DEC-2003 K.Boussema   Changed to fix bug 3042840,3307761,3268940    |
|                               3310291 and 3320689                          |
|     05-FEB-2004 K.Boussema   Reviewed get_mapping_flexfield_char/number    |
|     16-FEB-2004 K.Boussema   Made changes for the FND_LOG.                 |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema   Removed the call to XLA trace routine from    |
|                               trace() procedure                            |
|     17-May-2004 W.Shen       change the view name from xla_acctg_sources_tl|
|                               to xla_acct_attributes_tl                    |
|     22-Sep-2004 S.Singhania  Made minor changes for bulk performance:      |
|                                - Changes to calls to build_message.        |
|     17-Jan-2006 A.Wan        4731177 Do not error if no value found.       |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--+==========================================================================+
---
-- period type and name cache
--
g_period_name                        VARCHAR2(15);
g_period_type                        VARCHAR2(15);
g_period_ledger_id                   NUMBER;
g_period_date                        DATE;
--
--
-- Lookup meaning cache
--
g_meaning_lookup_type                VARCHAR2(30);
g_meaning_lookup_code                VARCHAR2(30);
g_meaning_lookup_language            VARCHAR2(30);
g_meaning_view_appl_id               NUMBER;
g_meaning_start_date                 DATE;
g_meaning_end_date                   DATE;
g_meaning_lookup                     VARCHAR2(80);
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_ae_sources_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE)
IS
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
             (p_location   => 'xla_ae_sources_pkg.trace');
END trace;
--
--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--| PUBLIC and Privates APIs to get the name in the language of teh session  |
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
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC   function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetApplicationName (p_application_id   IN NUMBER)
RETURN VARCHAR2
IS
l_application_name          VARCHAR2(240);
l_log_module                VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetApplicationName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetApplicationName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_application_id = '|| TO_CHAR(p_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF p_application_id  IS NOT NULL THEN

  SELECT  REPLACE(fat.application_name, '''','''''')
    INTO  l_application_name
    FROM  fnd_application_tl fat
   WHERE  fat.application_id = p_application_id
     AND  fat.language = nvl(USERENV('LANG'),fat.language)
     ;
--
ELSE
  l_application_name:= NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_application_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

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
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSourceName                                                      |
|                                                                       |
+======================================================================*/
FUNCTION GetSourceName(
  p_source_code           IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN VARCHAR2
IS
  l_source_name        VARCHAR2(240);
  l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSourceName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSourceName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_source_code = '|| p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_source_type_code = '|| p_source_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_source_application_id = '|| TO_CHAR(p_source_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
IF p_source_code IS NOT NULL THEN

  SELECT  REPLACE(xst.name, '''','''''')
    INTO  l_source_name
    FROM  xla_sources_tl   xst
   WHERE  xst.application_id   = p_source_application_id
     AND  xst.source_type_code = p_source_type_code
     AND  xst.source_code      = p_source_code
     AND  xst.language         = nvl(USERENV('LANG'),xst.language)
     ;
ELSE
   l_source_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_source_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetSourceName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_source_name;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_source_code;
END GetSourceName;
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC  function                                                         |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetAccountingSourceName (p_accounting_source_code   IN VARCHAR2)
RETURN VARCHAR2
IS
l_name               VARCHAR2(160);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAccountingSourceName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAccountingSourceName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_accounting_source_code = '|| p_accounting_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF p_accounting_source_code IS NOT NULL THEN

  SELECT  REPLACE(xast.name ,'''','''''')
    INTO  l_name
    FROM  xla_acct_attributes_tl xast
   WHERE  xast.accounting_attribute_code = p_accounting_source_code
     AND  xast.language = nvl(USERENV('LANG') ,xast.language)
     ;
--
ELSE
   l_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetAccountingSourceName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_name;

EXCEPTION
 WHEN OTHERS THEN
    RETURN p_accounting_source_code;
END GetAccountingSourceName;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetMappingSetName (
  p_mapping_set_code   IN VARCHAR2
, p_amb_context_code   IN VARCHAR2
)
RETURN VARCHAR2
IS
l_mapping_set_name          VARCHAR2(160);
l_log_module                VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetMappingSetName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetMappingSetName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_mapping_set_code = '|| p_mapping_set_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF p_mapping_set_code  IS NOT NULL THEN

  SELECT  REPLACE(xmst.name, '''','''''')
    INTO  l_mapping_set_name
    FROM  xla_mapping_sets_tl xmst
   WHERE  xmst.mapping_set_code = p_mapping_set_code
     AND  xmst.amb_context_code = nvl(p_amb_context_code,xmst.amb_context_code)
     AND  nvl(xmst.language,USERENV('LANG') ) = USERENV('LANG')
     ;
--
ELSE
  l_mapping_set_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_mapping_set_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetMappingSetName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_mapping_set_name;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_mapping_set_code;
END GetMappingSetName;
--
--
--+==========================================================================+
--|                                                                          |
--| Public  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetADRName (
  p_component_code        IN VARCHAR2
, p_component_type_code   IN VARCHAR2
, p_component_appl_id     IN INTEGER
, p_amb_context_code      IN VARCHAR2
)
RETURN VARCHAR2
IS
l_name               VARCHAR2(160);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetADRName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetADRName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_component_code = '|| p_component_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_component_type_code = '|| p_component_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_component_application_id = '|| TO_CHAR(p_component_appl_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

--
IF p_component_code IS NOT NULL THEN

  SELECT  REPLACE(xsrt.name, '''','''''')
    INTO  l_name
    FROM  xla_seg_rules_tl       xsrt
   WHERE  xsrt.application_id             =  p_component_appl_id
     AND  xsrt.amb_context_code           =  p_amb_context_code
     AND  xsrt.segment_rule_code          =  p_component_code
     AND  xsrt.segment_rule_type_code     =  p_component_type_code
     AND  nvl(xsrt.language,USERENV('LANG') ) = USERENV('LANG')
     ;
--
ELSE
 l_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetADRName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_name ;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_component_code;
END GetADRName;
--
--
--+==========================================================================+
--|                                                                          |
--| Public  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetDescriptionName (
  p_component_code        IN VARCHAR2
, p_component_type_code   IN VARCHAR2
, p_component_appl_id     IN INTEGER
, p_amb_context_code      IN VARCHAR2
)
RETURN VARCHAR2
IS
l_name               VARCHAR2(160);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetDescriptionName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetDescriptionName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_component_code = '|| p_component_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_component_type_code = '|| p_component_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_component_application_id = '|| TO_CHAR(p_component_appl_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
IF p_component_code IS NOT NULL THEN

  SELECT  REPLACE(xdtl.name, '''','''''')
    INTO  l_name
    FROM  xla_descriptions_tl       xdtl
   WHERE  xdtl.application_id             =  p_component_appl_id
     AND  xdtl.amb_context_code           =  p_amb_context_code
     AND  xdtl.description_code           =  p_component_code
     AND  xdtl.description_type_code      =  p_component_type_code
     AND  nvl(xdtl.language,USERENV('LANG') ) = USERENV('LANG')
     ;
--
ELSE
 l_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetDescriptionName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_name ;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_component_code;
END GetDescriptionName;
--
--
--+==========================================================================+
--|                                                                          |
--| Public  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetJLTName (
  p_component_code        IN VARCHAR2
, p_component_type_code   IN VARCHAR2
, p_component_appl_id     IN INTEGER
, p_amb_context_code      IN VARCHAR2
, p_entity_code           IN VARCHAR2
, p_event_class_code      IN VARCHAR2
)
RETURN VARCHAR2
IS
l_name               VARCHAR2(160);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetJLTName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetJLTName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_component_code = '|| p_component_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_component_type_code = '|| p_component_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_component_application_id = '|| TO_CHAR(p_component_appl_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_entity_code  = '|| p_entity_code
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_event_class_code  = '|| p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF p_component_code IS NOT NULL THEN

  SELECT  REPLACE(xaltt.name, '''','''''')
    INTO  l_name
    FROM  xla_acct_line_types_tl       xaltt
   WHERE  xaltt.application_id                 =  p_component_appl_id
     AND  xaltt.amb_context_code               =  p_amb_context_code
     AND  xaltt.entity_code                    =  p_entity_code
     AND  xaltt.event_class_code               =  p_event_class_code
     AND  xaltt.accounting_line_code           =  p_component_code
     AND  xaltt.accounting_line_type_code      =  p_component_type_code
     AND  nvl(xaltt.language,USERENV('LANG') ) = USERENV('LANG')
     ;
--
ELSE
 l_name := NULL;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'return value. = '||l_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => 'END of GetJLTName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_name ;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_component_code;
END GetJLTName;
--
--
--+==========================================================================+
--|                                                                          |
--| Public  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetComponentName  (
  p_component_type        IN VARCHAR2
, p_component_code        IN VARCHAR2
, p_component_type_code   IN VARCHAR2
, p_component_appl_id     IN INTEGER
, p_amb_context_code      IN VARCHAR2
, p_entity_code           IN VARCHAR2
, p_event_class_code      IN VARCHAR2
)
RETURN VARCHAR2
IS
l_name               VARCHAR2(80):=NULL;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetComponentName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetComponentName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
IF p_component_code IS NOT NULL THEN
--
CASE p_component_type
--
WHEN 'AMB_ADR' THEN
--
    l_name:= GetADRName (
      p_component_code
    , p_component_type_code
    , p_component_appl_id
    , p_amb_context_code
    );
--
WHEN 'AMB_JLT' THEN

    l_name:= GetJLTName (
         p_component_code
       , p_component_type_code
       , p_component_appl_id
       , p_amb_context_code
       , p_entity_code
       , p_event_class_code
     );


WHEN 'AMB_DESCRIPTION' THEN

    l_name:= GetADRName (
      p_component_code
    , p_component_type_code
    , p_component_appl_id
    , p_amb_context_code
    );
--
ELSE  null;
END CASE;
--
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
         (p_msg      => 'END of GetComponentName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_name ;
EXCEPTION
 WHEN OTHERS THEN
    RETURN p_component_code;
END GetComponentName ;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSystemSourceNum                                                 |
|                                                                       |
+======================================================================*/
FUNCTION GetSystemSourceNum(
  p_source_code           IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN NUMBER
IS
  l_system_value       NUMBER;
  l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSystemSourceNum';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSystemSourceNum'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_code = '|| p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_type_code = '|| p_source_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_application_id = '|| TO_CHAR(p_source_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueNum API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
        (p_msg      => 'END of GetSystemSourceNum'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
CASE  p_source_code

WHEN 'XLA_LEGAL_ENTITY_ID'        THEN

  RETURN xla_ae_journal_entry_pkg.g_cache_event.legal_entity_id;

WHEN 'XLA_REFERENCE_NUM_1'    THEN

    RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_num_1;

WHEN 'XLA_REFERENCE_NUM_2'    THEN

   RETURN  xla_ae_journal_entry_pkg.g_cache_event.reference_num_2;

WHEN 'XLA_REFERENCE_NUM_3'    THEN

   RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_num_3;

WHEN 'XLA_REFERENCE_NUM_4'    THEN

   RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_num_4;

WHEN 'LATEST_ENCUMBRANCE_YEAR'    THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );
WHEN 'SL_COA_MAPPING_ID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

WHEN 'SLA_LEDGER_ID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

WHEN 'XLA_COA_ID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

WHEN 'XLA_CURRENCY_PRECISION' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

WHEN 'XLA_ENTERED_CUR_BAL_SUS_CCID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

WHEN 'XLA_ENTRY_CREATED_BY' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          );

WHEN 'XLA_EVENT_APPL_ID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          );

WHEN 'XLA_LEDGER_CUR_BAL_SUS_CCID' THEN

   RETURN  xla_accounting_cache_pkg.GetValueNum
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );
  --
ELSE

   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg.build_message
                             (p_appli_s_name            => 'XLA'
                             ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                             ,p_token_1                 => 'SOURCE_NAME'
                             ,p_value_1                 => GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                             ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                             ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                             ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
    END IF;
    RETURN NULL;

END CASE;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg.build_message
                               (p_appli_s_name            => 'XLA'
                               ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                               ,p_token_1                 => 'SOURCE_NAME'
                               ,p_value_1                 =>GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                               ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                               ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                               ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_EXCEPTION
                   ,p_module   => l_log_module);
    END IF;

    RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.GetSystemSourceNum');
       --
END GetSystemSourceNum;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION GetSystemSourceDate(
  p_source_code           IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN DATE
IS
l_system_value       DATE;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSystemSourceDate';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSystemSourceDate'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_code = '|| p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_type_code = '|| p_source_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_application_id = '|| TO_CHAR(p_source_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
        (p_msg      => 'END of GetSystemSourceDate'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
CASE  p_source_code

WHEN 'XLA_EVENT_DATE'          THEN

   RETURN  xla_ae_journal_entry_pkg.g_cache_event.event_date;

WHEN 'XLA_TRANSACTION_DATE'          THEN

   RETURN  xla_ae_journal_entry_pkg.g_cache_event.transaction_date;

WHEN 'XLA_REFERENCE_DATE_1'    THEN

   RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_date_1;

WHEN 'XLA_REFERENCE_DATE_2'    THEN

   RETURN  xla_ae_journal_entry_pkg.g_cache_event.reference_date_2;

WHEN 'XLA_REFERENCE_DATE_3'    THEN

   RETURN  xla_ae_journal_entry_pkg.g_cache_event.reference_date_3;

WHEN 'XLA_REFERENCE_DATE_4'    THEN

  RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_date_4;

WHEN 'XLA_CREATION_DATE'    THEN

  RETURN xla_accounting_cache_pkg.GetValueDate
          (
            p_source_code     => p_source_code
          );
ELSE

  xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
  xla_accounting_err_pkg.build_message
                             (p_appli_s_name            => 'XLA'
                             ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                             ,p_token_1                 => 'SOURCE_NAME'
                             ,p_value_1                 => GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                             ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                             ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                             ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
    END IF;

   RETURN NULL;

END CASE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg.build_message
                               (p_appli_s_name            => 'XLA'
                               ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                               ,p_token_1                 => 'SOURCE_NAME'
                               ,p_value_1                 => GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                               ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                               ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                               ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_EXCEPTION
                   ,p_module   => l_log_module);
    END IF;

    RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.GetSystemSourceDate');
       --
END GetSystemSourceDate;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSystemSourceChar                                                |
|                                                                       |
+======================================================================*/
FUNCTION GetSystemSourceChar(
  p_source_code           IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
                           )
RETURN VARCHAR2
IS
l_closing_status       VARCHAR2(1);
l_system_value         VARCHAR2(4000);
l_log_module           VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSystemSourceChar';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSystemSourceChar'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_code = '|| p_source_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_type_code = '|| p_source_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_source_application_id = '|| TO_CHAR(p_source_application_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
CASE  p_source_code

WHEN 'XLA_JE_CATEGORY_NAME'                THEN

  l_system_value := xla_accounting_cache_pkg.get_je_category(
               p_ledger_id        => xla_ae_journal_entry_pkg.g_cache_event.base_ledger_id
              ,p_event_class_code => xla_ae_journal_entry_pkg.g_cache_event.event_class
             );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
         (p_msg      => '-> CALL xla_accounting_cache_pkg.get_je_category API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'ALLOW_INTERCOMPANY_POST_FLAG'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'BAL_SEG_COLUMN_NAME '        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'BAL_SEG_VALUE_OPTION_CODE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
          );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'CONTROL_ACCOUNT_ENABLED_FLAG'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'GL_COA_MAPPING_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'LEDGER_CATEGORY_CODE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'MGT_SEG_COLUMN_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'MGT_SEG_VALUE_OPTION_CODE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'SLA_BAL_BY_LEDGER_CURR_FLAG'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'VALUATION_METHOD_FLAG'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_ACCOUNTING_METHOD_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_ACCOUNTING_METHOD_OWNER'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_ACCT_REVERSAL_OPTION'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_COA_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_CURRENCY_CODE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_DESCRIPTION_LANGUAGE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_ENTITY_CODE' THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_event.entity_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_EVENT_APPL_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_EVENT_APPL_SHORT_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_EVENT_CLASS_CODE' THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_event.event_class;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_EVENT_CLASS_NAME' THEN

  l_system_value :=xla_ae_journal_entry_pkg.g_cache_event_tl.event_class_name;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;


WHEN 'XLA_EVENT_CREATED_BY'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_event.event_created_by;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_EVENT_TYPE_CODE'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_event.event_type;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;
--
WHEN 'XLA_EVENT_TYPE_NAME'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_event_tl.event_type_name;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_JE_SOURCE_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_LEDGER_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_NLS_DESC_LANGUAGE'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_PAD_CODE'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_pad.product_rule_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_PAD_COMPILE_STATUS'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_pad.pad_compile_status;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;


WHEN 'XLA_PAD_NAME'        THEN

  l_system_value :=xla_ae_journal_entry_pkg.g_cache_pad.product_rule_name;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;


WHEN 'XLA_PAD_OWNER'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_pad.product_rule_type_code;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_PAD_PACKAGE_NAME'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_pad.pad_package_name;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;

WHEN 'XLA_PAD_VERSION'        THEN

  l_system_value := xla_ae_journal_entry_pkg.g_cache_pad.product_rule_version;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;


WHEN 'XLA_PERIOD_NAME'        THEN
--
  IF g_period_ledger_id = xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id AND
     g_period_date      = xla_ae_journal_entry_pkg.g_cache_event.event_date
  THEN
     NULL;
  ELSE
    g_period_name   := xla_je_validation_pkg.get_period_name
                 (p_ledger_id          => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                 ,p_accounting_date    => xla_ae_journal_entry_pkg.g_cache_event.event_date
                 ,p_closing_status     => l_closing_status
                 ,p_period_type        => g_period_type
                 );
     --
    g_period_ledger_id     := xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id;
    g_period_date          := xla_ae_journal_entry_pkg.g_cache_event.event_date;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_je_validation_pkg.get_period_name API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||g_period_name
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN g_period_name;
--
WHEN 'XLA_PERIOD_TYPE'   THEN
--
--
  IF g_period_ledger_id = xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id AND
     g_period_date      = xla_ae_journal_entry_pkg.g_cache_event.event_date
  THEN
       NULL;
  ELSE
    g_period_name   := xla_je_validation_pkg.get_period_name
                 (p_ledger_id          => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                 ,p_accounting_date    => xla_ae_journal_entry_pkg.g_cache_event.event_date
                 ,p_closing_status     => l_closing_status
                 ,p_period_type        => g_period_type
                 );
     --
    g_period_ledger_id     := xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id;
    g_period_date          := xla_ae_journal_entry_pkg.g_cache_event.event_date;
  END IF;
  --
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => '-> CALL xla_je_validation_pkg.get_period_name API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '||g_period_type
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN g_period_type;
--

WHEN 'XLA_REFERENCE_CHAR_1'    THEN

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||xla_ae_journal_entry_pkg.g_cache_event.reference_char_1
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_char_1;

WHEN 'XLA_REFERENCE_CHAR_2'    THEN

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||xla_ae_journal_entry_pkg.g_cache_event.reference_char_2
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_char_2;

WHEN 'XLA_REFERENCE_CHAR_3'    THEN

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||xla_ae_journal_entry_pkg.g_cache_event.reference_char_3
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN xla_ae_journal_entry_pkg.g_cache_event.reference_char_3;

WHEN 'XLA_REFERENCE_CHAR_4'    THEN

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '||xla_ae_journal_entry_pkg.g_cache_event.reference_char_4
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
 END IF;
 RETURN  xla_ae_journal_entry_pkg.g_cache_event.reference_char_4;

WHEN 'XLA_USER_JE_SOURCE_NAME'        THEN

  l_system_value := xla_accounting_cache_pkg.GetValueChar
          (
            p_source_code       => p_source_code
          , p_target_ledger_id  => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar API'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
           (p_msg      => 'return value. = '|| l_system_value
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetSystemSourceChar'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
  END IF;
  RETURN l_system_value ;
ELSE

  xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
  xla_accounting_err_pkg.build_message
                             (p_appli_s_name            => 'XLA'
                             ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                             ,p_token_1                 => 'SOURCE_NAME'
                             ,p_value_1                 => GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                             ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                             ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                             ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
  END IF;
  RETURN NULL;

END CASE;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg.build_message
                               (p_appli_s_name            => 'XLA'
                               ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                               ,p_token_1                 => 'SOURCE_NAME'
                               ,p_value_1                 => GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
                               ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                               ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                               ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
           );

    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_EXCEPTION
                   ,p_module   => l_log_module);
    END IF;

    RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.GetSystemSourceChar');
       --
END GetSystemSourceChar;
--
--
--+==========================================================================+
--| PUBLIC  procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|   GetTranslatedLookupMeaning                                             |
--|                                                                          |
--|   GetUnTranslatedLookupMeaning                                           |
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
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION GetLookupMeaning(
  p_lookup_code            IN VARCHAR2
, p_lookup_type            IN VARCHAR2
, p_view_application_id    IN NUMBER
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN INTEGER
)
RETURN VARCHAR2

IS

l_language          VARCHAR2(30):=xla_ae_journal_entry_pkg.g_cache_ledgers_info.description_language;
l_event_date        DATE        :=xla_ae_journal_entry_pkg.g_cache_event.event_date;
l_log_module        VARCHAR2(240);

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLookupMeaning';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetLookupMeaning'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_lookup_code = '|| p_lookup_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_lookup_type = '|| p_lookup_type
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
          (p_msg      => 'p_view_application_id = '|| p_view_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

    trace
         (p_msg      => 'p_source_code = '|| p_source_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

    trace
         (p_msg      => 'p_source_type_code = '|| p_source_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

    trace
         (p_msg      => 'p_source_application_id = '|| p_source_application_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--

IF g_meaning_lookup_type     = p_lookup_type                     AND
   g_meaning_lookup_code     = p_lookup_code                     AND
   g_meaning_lookup_language = NVL(l_language , USERENV('LANG')) AND
   g_meaning_view_appl_id    = p_view_application_id             AND
   l_event_date BETWEEN g_meaning_start_date AND g_meaning_end_date
THEN

   NULL;

ELSIF p_lookup_code IS NOT NULL AND p_lookup_type IS NOT NULL THEN

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'SQL - Select from fnd_lookup_values'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

SELECT meaning,
       start_date_active,
       end_date_active
  INTO g_meaning_lookup
      ,g_meaning_start_date
      ,g_meaning_end_date
  FROM fnd_lookup_values
 WHERE  lookup_type         = p_lookup_type
   AND  lookup_code         = p_lookup_code
   AND  view_application_id = p_view_application_id
   AND  language            = NVL(l_language , USERENV('LANG'))
   AND  enabled_flag        = 'Y'
   AND  l_event_date BETWEEN nvl(start_date_active,l_event_date)  AND nvl (end_date_active, l_event_date)
;

g_meaning_lookup_type                := p_lookup_type;
g_meaning_lookup_code                := p_lookup_code;
g_meaning_lookup_language            := NVL(l_language , USERENV('LANG'));
g_meaning_view_appl_id               := p_view_application_id;

ELSE

  g_meaning_lookup:= NULL;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'return value. = '|| g_meaning_lookup
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

        trace
          (p_msg      => 'END of GetLookupMeaning'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;

RETURN g_meaning_lookup;

EXCEPTION
WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN

   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg. build_message
               (p_appli_s_name            => 'XLA'
               ,p_msg_name                => 'XLA_AP_NO_LOOKUP_MEANING'
               ,p_token_1                 => 'SOURCE_NAME'
               ,p_value_1                 =>  GetSourceName(
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

   RETURN NULL;
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.GetLookupMeaning');
       --
END GetLookupMeaning;
--
--
--+==========================================================================+
--| PUBLIC  procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|   mapping set                                                            |
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
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_mapping_flexfield_number (
   p_component_type      IN VARCHAR2
 , p_component_code      IN VARCHAR2
 , p_component_type_code IN VARCHAR2
 , p_component_appl_id   IN INTEGER
 , p_amb_context_code    IN VARCHAR2
 , p_mapping_set_code    IN VARCHAR2
 , p_input_constant      IN VARCHAR2
 , p_ae_header_id        IN NUMBER
 )
 RETURN NUMBER
 IS
 --
 l_result               NUMBER;
 l_default              NUMBER;
 l_event_date           DATE := xla_ae_journal_entry_pkg.g_cache_event.event_date;
 l_exists               BOOLEAN:= FALSE;
 --
 --
 CURSOR value_cur( p_mapping_set_code   VARCHAR2
                 , p_input_constant     VARCHAR2
                 , p_event_date         DATE
                )
 IS
 --
 SELECT   xmsv.value_code_combination_id
       ,  xmsv.input_value_type_code
    FROM  xla_mapping_set_values  xmsv
   WHERE  xmsv.mapping_set_code    = p_mapping_set_code
     AND  ( p_event_date  BETWEEN NVL(xmsv.effective_date_from,p_event_date)
                              AND NVL(xmsv.effective_date_to,p_event_date) )
     AND ( ( xmsv.input_value_type_code  ='I'
           AND xmsv.input_value_constant = p_input_constant
           )
           OR
           ( xmsv.input_value_type_code = 'D'
            )
         )
     AND enabled_flag = 'Y'
     AND amb_context_code = p_amb_context_code;
 -- 8501964 changed where clause to include amb_context_code and remove nvl
 --
 l_log_module         VARCHAR2(240);
 BEGIN
 --
 IF g_log_enabled THEN
       l_log_module := C_DEFAULT_MODULE||'.get_mapping_flexfield_number';
 END IF;
--
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
          (p_msg      => 'BEGIN of get_mapping_flexfield_number'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_mapping_set_code = '|| p_mapping_set_code
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
           (p_msg      => 'p_input_constant = '|| p_input_constant
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

      trace
           (p_msg      => 'l_event_date = '|| TO_CHAR(l_event_date)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

 END IF;
 --
 l_result              := NULL;
 l_default             := NULL;
 --
 l_exists               := FALSE;
 --
 --
 IF (C_LEVEL_STATEMENT >= g_log_level) THEN

     trace
          (p_msg      => 'p_component_type = '|| p_component_type
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

     trace
          (p_msg      => 'p_component_code = '|| p_component_code
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

     trace
          (p_msg      => 'p_component_type_code = '|| p_component_type_code
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

     trace
          (p_msg      => 'p_component_appl_id = '|| p_component_appl_id
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

     trace
          (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

      trace
           (p_msg      => 'SQL- Select from xla_mapping_set_values '
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
 END IF;
--
  FOR value_rec IN value_cur(  p_mapping_set_code   => p_mapping_set_code
                             , p_input_constant     => p_input_constant
                             , p_event_date         => l_event_date
                            )
  LOOP
  --

   IF value_rec.input_value_type_code = 'I' THEN
       --
       l_result := value_rec.value_code_combination_id;
       l_exists := TRUE;
       --
    ELSIF value_rec.input_value_type_code = 'D' THEN
       --
       l_default := value_rec.value_code_combination_id;
       l_exists := TRUE;
       --
   END IF;
  --
  END LOOP;
  --
 l_result := NVL(l_result,l_default);

/* 4731177 Do not error if no value found
 IF NOT l_exists THEN
    l_result:= NULL;
    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                    (p_appli_s_name            => 'XLA'
                    ,p_msg_name                => 'XLA_AP_MAPPING_SET'
                    ,p_token_1                 => 'SOURCE_VALUE'
                    ,p_value_1                 => p_input_constant
                    ,p_token_2                 => 'MAPPING_SET_NAME'
                    ,p_value_2                 => GetMappingSetName(
                                                   p_mapping_set_code
                                                 , p_amb_context_code
                                                  )
                    ,p_token_3                 => 'COMPONENT_NAME'
                    ,p_value_3                 =>   GetComponentName  (
                                                            p_component_type
                                                          , p_component_code
                                                          , p_component_type_code
                                                          , p_component_appl_id
                                                          , p_amb_context_code
                                                          )
                    ,p_token_4                 => 'OWNER'
                    ,p_value_4                 => xla_lookups_pkg.get_meaning(
                                                            'XLA_OWNER_TYPE'
                                                           , p_component_type_code)
                    ,p_token_5                 => 'PAD_NAME'
                    ,p_value_5                 => xla_ae_journal_entry_pkg.g_cache_pad.pad_session_name
                    ,p_token_6                 => 'PAD_OWNER'
                    ,p_value_6                 =>  xla_lookups_pkg.get_meaning(
                                                          'XLA_OWNER_TYPE'
                                                          ,xla_ae_journal_entry_pkg.g_cache_pad.product_rule_type_code
                                                         )
                    ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                    ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                    ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                    ,p_ae_header_id            => NULL -- p_ae_header_id
                      );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_MAPPING_SET'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
    END IF;

 END IF;
*/

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'return value. = '|| l_result
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

         trace
           (p_msg      => 'END of get_mapping_flexfield_number'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.get_mapping_flexfield_number');
END get_mapping_flexfield_number;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_mapping_flexfield_char (
   p_component_type      IN VARCHAR2
 , p_component_code      IN VARCHAR2
 , p_component_type_code IN VARCHAR2
 , p_component_appl_id   IN INTEGER
 , p_amb_context_code    IN VARCHAR2
 , p_mapping_set_code    IN VARCHAR2
 , p_input_constant      IN VARCHAR2
 , p_ae_header_id        IN NUMBER
 )
 RETURN VARCHAR2
 IS
 --
 l_event_date           DATE := xla_ae_journal_entry_pkg.g_cache_event.event_date;
 --
 CURSOR value_cur(  p_mapping_set_code   VARCHAR2
                  , p_input_constant     VARCHAR2
                  , p_event_date         DATE
                )
 IS
 --
 SELECT   xmsv.value_constant
       ,  xmsv.input_value_type_code
    FROM  xla_mapping_set_values  xmsv
   WHERE  xmsv.mapping_set_code    = p_mapping_set_code
     AND  ( p_event_date  BETWEEN NVL(xmsv.effective_date_from,p_event_date)
                              AND NVL(xmsv.effective_date_to,p_event_date) )
     AND ( ( xmsv.input_value_type_code ='I'
           AND xmsv.input_value_constant = p_input_constant )
           OR   xmsv.input_value_type_code = 'D'
         )
     AND enabled_flag = 'Y'
     AND amb_context_code = p_amb_context_code;

 -- 8501964 changed where clause to include amb_context_code and remove nvl
 --
 l_result               VARCHAR2(240);
 l_default              VARCHAR2(240);
 l_exists               BOOLEAN:= FALSE;
 l_log_module           VARCHAR2(240);
 BEGIN
  --
  IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.get_mapping_flexfield_char';
  END IF;
--
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
          (p_msg      => 'BEGIN of get_mapping_flexfield_char'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_mapping_set_code = '|| p_mapping_set_code
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
           (p_msg      => 'p_input_constant = '|| p_input_constant
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

      trace
           (p_msg      => 'l_event_date = '|| TO_CHAR(l_event_date)
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

 END IF;
 --
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
           (p_msg      => 'p_component_type = '|| p_component_type
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);

      trace
           (p_msg      => 'p_component_code = '|| p_component_code
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);

      trace
           (p_msg      => 'p_component_type_code = '|| p_component_type_code
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);

      trace
           (p_msg      => 'p_component_appl_id = '|| p_component_appl_id
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);

      trace
           (p_msg      => 'p_amb_context_code = '|| p_amb_context_code
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);

       trace
            (p_msg      => 'SQL- Select from xla_mapping_set_values '
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
 END IF;
--
 l_result              := NULL;
 l_default             := NULL;
 l_exists              := FALSE;
 --
 FOR value_rec IN value_cur(  p_mapping_set_code   => p_mapping_set_code
                            , p_input_constant     => p_input_constant
                            , p_event_date         => l_event_date
                           )
  LOOP
  --
    IF value_rec.input_value_type_code = 'I' THEN
       --
       l_result := value_rec.value_constant;
       l_exists := TRUE;
       --
    ELSIF value_rec.input_value_type_code = 'D' THEN
       --
       l_default := value_rec.value_constant;
       l_exists := TRUE;
       --
    END IF;
  --
  END LOOP;
  --
 l_result := NVL(l_result,l_default);
 --
/* 4731177 Do not error if no value found
 IF  NOT l_exists THEN
    l_result:= NULL;
    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                    (p_appli_s_name            => 'XLA'
                    ,p_msg_name                => 'XLA_AP_MAPPING_SET'
                    ,p_token_1                 => 'SOURCE_VALUE'
                    ,p_value_1                 => p_input_constant
                    ,p_token_2                 => 'MAPPING_SET_NAME'
                    ,p_value_2                 => GetMappingSetName(
                                                   p_mapping_set_code
                                                 , p_amb_context_code
                                                  )
                    ,p_token_3                 => 'COMPONENT_NAME'
                    ,p_value_3                 =>    GetComponentName  (
                                                            p_component_type
                                                          , p_component_code
                                                          , p_component_type_code
                                                          , p_component_appl_id
                                                          , p_amb_context_code
                                                          )
                    ,p_token_4                 => 'OWNER'
                    ,p_value_4                 =>  xla_lookups_pkg.get_meaning(
                                                            'XLA_OWNER_TYPE'
                                                           , p_component_type_code)
                    ,p_token_5                 => 'PAD_NAME'
                    ,p_value_5                 => xla_ae_journal_entry_pkg.g_cache_pad.pad_session_name
                    ,p_token_6                 => 'PAD_OWNER'
                    ,p_value_6                 =>  xla_lookups_pkg.get_meaning(
                                                                'XLA_OWNER_TYPE'
                                                                ,xla_ae_journal_entry_pkg.g_cache_pad.product_rule_type_code
                                                                )
                    ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                    ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                    ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                    ,p_ae_header_id            => NULL -- p_ae_header_id
                      );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_MAPPING_SET'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
    END IF;

 END IF;
*/

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'return value. = '|| l_result
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

         trace
           (p_msg      => 'END of get_mapping_flexfield_char'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
--
 --
 RETURN l_result;
 --
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.get_mapping_flexfield_char');
 END get_mapping_flexfield_char;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|      Convert date into varchar according to the description language  |
|                                                                       |
+======================================================================*/
FUNCTION DATE_TO_CHAR (
   p_date               IN DATE
  ,p_nls_desc_language  IN VARCHAR2
 )
RETURN VARCHAR2
IS
l_date_language     VARCHAR2(200);
l_date_format       VARCHAR2(200);
l_log_module        VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.DATE_TO_CHAR';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

       trace
          (p_msg      => 'BEGIN of DATE_TO_CHAR'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
          (p_msg      => 'p_date = '|| p_date
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

       trace
           (p_msg      => 'p_nls_desc_language = '|| p_nls_desc_language
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);

 END IF;
 --

l_date_language := 'nls_date_language= '''||p_nls_desc_language||'''';
l_date_format   := SYS_CONTEXT('USERENV','NLS_DATE_FORMAT');
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'return value. = '|| TO_CHAR(p_date,l_date_format,l_date_language)
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

         trace
           (p_msg      => 'END of DATE_TO_CHAR'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;

RETURN TO_CHAR(p_date,l_date_format,l_date_language);
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_sources_pkg.DATE_TO_CHAR');
END DATE_TO_CHAR;
--
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

END xla_ae_sources_pkg; --

/
