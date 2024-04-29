--------------------------------------------------------
--  DDL for Package Body XLA_CMP_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_SOURCE_PKG" AS
/* $Header: xlacpscs.pkb 120.28.12010000.2 2008/12/10 11:49:18 svellani ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_source_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to cache the sources and entities/objects defined in the AMB           |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     14-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|                               Changed GetObjParm                           |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143  |
|     24-JUN-2003 K.Boussema    Reviewed GetSystemSource function bug2990642 |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     19-NOV-2003 K.Boussema    Updated the function InsertDerivedSource to  |
|                               fix bug 3263242                              |
|     20-NOV-2003 K.Boussema    Changed to fix bug 3266355 and bug 3269101   |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                               trace() procedure                            |
|     02-JUN-2004 A.Quaglia     Added get_obj_parm_for_tab                   |
|                               Modified GetObjParm                          |
|     21-Sep-2004 S.Singhania   Made ffg changes for the Bulk Performance:   |
|                                 - Modified routines GetStandardSource and  |
|                                   GetMeaningSource.                        |
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--| Global CONSTANTS                                                         |
--|                                                                          |
--+==========================================================================+
--
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
--
C_UNTRANSLATED                     CONSTANT    VARCHAR2(1)  := 'N';
C_TRANSLATED                       CONSTANT    VARCHAR2(1)  := 'Y';
--
--
C_SYSTEM_SOURCE_TYPE               CONSTANT    VARCHAR2(1)  := 'Y';
C_SEEDED_SOURCE_TYPE               CONSTANT    VARCHAR2(1)  := 'S';
C_CUSTOM_SOURCE_TYPE               CONSTANT    VARCHAR2(1)  := 'D';
--
--
C_DATE_DATATYPE                    CONSTANT    VARCHAR2(1)  := 'D';
C_NUMBER_DATATYPE                  CONSTANT    VARCHAR2(1)  := 'N';
C_INTEGER_DATATYPE                 CONSTANT    VARCHAR2(1)  := 'I';
C_CHAR_DATATYPE                    CONSTANT    VARCHAR2(1)  := 'C';
C_FLEXFIELD_DATATYPE               CONSTANT    VARCHAR2(1)  := 'F';

--Addition for the Transaction Account Builder
g_component_type                   VARCHAR2(30);

--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|    Generate GetMeaning API for the source associated to value set        |
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
--======================================================================
--
-- get_meaning function
--
C_GET_MEANING_FTC_NULL                CONSTANT      VARCHAR2(10000):= '
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
           (p_location => ''$package_name$.GetMeaning'');
END GetMeaning;
--
';
--
--
-- get_meaning function
--
C_GET_MEANING_FTC                    CONSTANT      VARCHAR2(32000):= '
--
---------------------------------------
--
-- PUBLIC FUNCTION
--         GetMeaning
--
---------------------------------------
FUNCTION GetMeaning (
  p_flex_value_set_id               IN INTEGER
, p_flex_value                      IN VARCHAR2
, p_source_code                     IN VARCHAR2
, p_source_type_code                IN VARCHAR2
, p_source_application_id           IN INTEGER
)
RETURN VARCHAR2
IS
l_meaning_meaning                     VARCHAR2(4000);
l_Idx                                 INTEGER;
l_log_module                          VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||''.GetMeaning'';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''BEGIN of GetMeaning''||
                        ''p_flex_value_set_id = ''||p_flex_value_set_id||
                        ''p_flex_value = ''||p_flex_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
-- Commenting out as part of bug 7592259
--l_array_meaning := xla_ae_sources_pkg.g_array_meaning;
--
IF p_flex_value IS NULL THEN

  l_meaning_meaning := NULL;

ELSE

 CASE p_flex_value_set_id
      $body$
 ELSE
         l_meaning_meaning  := NULL;
         xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
         xla_accounting_err_pkg.build_message
                        (p_appli_s_name            => ''XLA''
                        ,p_msg_name                => ''XLA_AP_FLEX_VALUE_MEANING''
                        ,p_token_1                 => ''VALUE_SET_NAME''
                        ,p_value_1                 =>  xla_flex_pkg.get_value_set_name(p_flex_value_set_id)
                        ,p_token_2                 => ''FLEX_VALUE''
                        ,p_value_2                 =>  p_flex_value
                        ,p_token_3                 => ''SOURCE_NAME''
                        ,p_value_3                 =>  xla_ae_sources_pkg.GetSourceName(
                                                     p_source_code
                                                   , p_source_type_code
                                                   , p_source_application_id
                                                     )
                        ,p_token_4                 => ''PRODUCT_NAME''
                        ,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
                        ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                        ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                        ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
        );
      IF (C_LEVEL_ERROR >= g_log_level) THEN
                         trace
                            (p_msg      => ''ERROR: XLA_AP_FLEX_VALUE_MEANING''
                            ,p_level    => C_LEVEL_ERROR
                            ,p_module   => l_log_module);
     END IF;
 END CASE;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''return value. meaning = ''||l_meaning_meaning
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => ''END of GetMeaning''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
--xla_ae_sources_pkg.g_array_meaning := l_array_meaning ;
--
RETURN l_meaning_meaning ;
--
EXCEPTION
WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
 --
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
      xla_accounting_err_pkg.build_message
                (p_appli_s_name            => ''XLA''
                ,p_msg_name                => ''XLA_AP_FLEX_VALUE_MEANING''
                ,p_token_1                 => ''VALUE_SET_NAME''
                ,p_value_1                 =>  xla_flex_pkg.get_value_set_name(p_flex_value_set_id)
                ,p_token_2                 => ''FLEX_VALUE''
                ,p_value_2                 =>  p_flex_value
                ,p_token_3                 => ''SOURCE_NAME''
                ,p_value_3                 =>  xla_ae_sources_pkg.GetSourceName(
                                                     p_source_code
                                                   , p_source_type_code
                                                   , p_source_application_id
                                                     )
                ,p_token_4                 => ''PRODUCT_NAME''
                ,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
                ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
        );

     IF (C_LEVEL_ERROR >= g_log_level) THEN
                         trace
                            (p_msg      => ''ERROR: XLA_AP_FLEX_VALUE_MEANING''
                            ,p_level    => C_LEVEL_ERROR
                            ,p_module   => l_log_module);
     END IF;

     RETURN NULL;
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => ''$package_name$.GetMeaning'');
END GetMeaning;
--
';
--
--
--=====================================================================

C_WHEN_THEN         CONSTANT      VARCHAR2(4000):= '
   WHEN $flex_value_set_id$ THEN

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''-> CALL  DBMS_UTILITY.get_hash_value''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

    END IF;

    l_Idx := DBMS_UTILITY.get_hash_value(TO_CHAR(p_flex_value),1,1073741824);

    IF xla_ae_sources_pkg.g_array_meaning.EXISTS($flex_value_set_id$) AND
       xla_ae_sources_pkg.g_array_meaning($flex_value_set_id$).array_flex_value.EXISTS(l_Idx) AND
       xla_ae_sources_pkg.g_array_meaning($flex_value_set_id$).array_flex_value(l_Idx)   = p_flex_value
       THEN

       l_meaning_meaning    := xla_ae_sources_pkg.g_array_meaning($flex_value_set_id$).array_meaning(l_Idx);

    ELSE

     $meaning_meaning$
     xla_ae_sources_pkg.g_array_meaning($flex_value_set_id$).array_flex_value(l_Idx)       := p_flex_value;
     xla_ae_sources_pkg.g_array_meaning($flex_value_set_id$).array_meaning(l_Idx)          := l_meaning_meaning;

    END IF;
';
--
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_source_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2) IS
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
             (p_location   => 'xla_cmp_source_pkg.trace');
END trace;
--

/*-------------------------------------------------------+
| Private function                                       |
|                                                        |
|   GetDataType                                          |
|                                                        |
|   It generates the source datatype in the AAD packages |
|                                                        |
+--------------------------------------------------------*/
FUNCTION GetDataType(p_Datatype_code IN VARCHAR2)
RETURN VARCHAR2
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetDataType';
END IF;
  CASE p_Datatype_code
    WHEN C_NUMBER_DATATYPE    THEN  RETURN 'NUMBER';
    WHEN C_INTEGER_DATATYPE   THEN  RETURN 'PLS_INTEGER';
    WHEN C_FLEXFIELD_DATATYPE THEN  RETURN 'NUMBER';
    WHEN C_DATE_DATATYPE      THEN  RETURN 'DATE';
    WHEN C_CHAR_DATATYPE      THEN  RETURN 'VARCHAR2';
    ELSE
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR : invalid datatype ='|| p_Datatype_code
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RETURN NULL;
  END CASE;
END GetDataType;

/*------------------------------------------------------------+
| Private function                                            |
|                                                             |
|   GetStandardSource                                         |
|                                                             |
|   It generates the call to standard sources in AAD packages |
|   according to the p_variable value                         |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GetStandardSource(
   p_Index                        IN BINARY_INTEGER
 , p_array_source_code            IN t_array_VL30
 , p_array_datatype_code          IN t_array_VL1
 , p_variable                     IN VARCHAR2
 )
RETURN VARCHAR2
IS
l_source             VARCHAR2(10000);
l_variable           VARCHAR2(1);
l_error_message      VARCHAR2(4000);
l_log_module         VARCHAR2(240);
invalid_source       EXCEPTION;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetStandardSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetStandardSource '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_variable := NVL(p_variable,'N');
l_source   := NULL;

IF  NOT p_array_source_code.EXISTS(p_Index) OR
    p_array_source_code(p_Index)  IS NULL THEN
    l_error_message := 'Source Index '||p_Index||' does not exist in the source cache';
    raise invalid_source;
END IF;

CASE  l_variable
   WHEN 'H' THEN    -- header variable
      l_source := 'g_array_event(l_event_id).array_value_$datatype$(''source_$index$'')';
      l_source := REPLACE(l_source, '$index$', p_index);
      CASE p_array_datatype_code(p_Index)
           WHEN 'F' THEN l_source  := REPLACE(l_source,'$datatype$','num') ;
           WHEN 'N' THEN l_source  := REPLACE(l_source,'$datatype$','num') ;
           WHEN 'C' THEN l_source  := REPLACE(l_source,'$datatype$','char') ;
           WHEN 'D' THEN l_source  := REPLACE(l_source,'$datatype$','date') ;
           ELSE l_source  := REPLACE(l_source,'$datatype$',p_array_datatype_code(p_Index)) ;
      END CASE;
   WHEN 'L' THEN   l_source  := 'l_array_source_'||p_Index||'(Idx)';
   WHEN 'N' THEN   l_source  := 'p_source_'||p_Index;
   ELSE
      l_error_message := 'Invalid parameter variable =' ||p_variable||' for source Index ='||p_Index;
      RAISE invalid_source;
END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetStandardSource '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
    END IF;
    RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetStandardSource');
END GetStandardSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetStandardSource                                       |
|                                                           |
|  It generates the call to source meanings in AAD packages |
|  according to the p_variable value                        |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GetMeaningSource(
    p_Index                        IN BINARY_INTEGER
  , p_array_source_code            IN t_array_VL30
  , p_variable                     IN VARCHAR2
 )
RETURN VARCHAR2
IS
l_source             VARCHAR2(10000);
l_variable           VARCHAR2(1);
l_log_module         VARCHAR2(240);
l_error_message      VARCHAR2(4000);
invalid_source       EXCEPTION;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetMeaningSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetMeaningSource '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_variable := NVL(p_variable,'N');
l_source   := NULL;

IF NOT p_array_source_code.EXISTS(p_Index) OR
    p_array_source_code(p_Index) IS NULL THEN
    l_error_message := 'Source Index '||p_Index||' does not exist in the source cache';
    RAISE invalid_source;
END IF;

CASE  l_variable
    WHEN 'H' THEN
     l_source := 'g_array_event(l_event_id).array_value_char(''source_$index$_meaning'')';
     l_source := REPLACE(l_source, '$index$', p_index);
    WHEN 'L' THEN  l_source  := 'l_array_source_'||p_Index||'_meaning(Idx)';
    WHEN 'N' THEN  l_source  := 'p_source_'||p_Index||'_meaning';
    ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         l_error_message := ' p_variable value ='||l_variable||' passed is invalid';
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
       END IF;
      l_source  := 'NULL';
END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetMeaningSource '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
   END IF;
   RETURN 'NULL';
   WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
    END IF;
    RETURN 'NULL';
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetMeaningSource');
END GetMeaningSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetSystemSource                                         |
|                                                           |
|  It generates the call to system sources in AAD packages  |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GetSystemSource(
   p_Index                        IN BINARY_INTEGER
 , p_rec_sources                  IN t_rec_sources
 )
RETURN VARCHAR2
IS

C_SYSTEM_SOURCE                      CONSTANT     VARCHAR2(10000) := '
xla_ae_sources_pkg.GetSystemSource$type$(
   p_source_code           => ''$source$''
 , p_source_type_code      => ''$source_type_code$''
 , p_source_application_id =>  $source_application_id$
)';

l_source                VARCHAR2(10000);
l_error_message         VARCHAR2(4000);
invalid_source          EXCEPTION;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSystemSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSystemSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF NOT p_rec_sources.array_source_code.EXISTS(p_Index) OR
    p_rec_sources.array_source_code(p_Index) IS NULL THEN
    l_error_message := 'Source Index '||p_Index||' does not exist in the source cache';
    RAISE invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||p_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||p_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||p_rec_sources.array_application_id(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_source  := C_SYSTEM_SOURCE;
l_source  := REPLACE(l_source,'$source$'               , p_rec_sources.array_source_code(p_Index));
l_source  := REPLACE(l_source,'$source_type_code$'     , p_rec_sources.array_source_type_code(p_Index));
l_source  := REPLACE(l_source,'$source_application_id$', p_rec_sources.array_application_id(p_Index));
CASE p_rec_sources.array_datatype_code(p_Index)

 WHEN C_NUMBER_DATATYPE    THEN l_source  := REPLACE(l_source,'$type$'  ,'Num');
 WHEN C_DATE_DATATYPE      THEN l_source  := REPLACE(l_source,'$type$'  ,'Date');
 WHEN C_CHAR_DATATYPE      THEN l_source  := REPLACE(l_source,'$type$'  ,'Char');
 WHEN C_FLEXFIELD_DATATYPE THEN l_source  := REPLACE(l_source,'$type$'  ,'Num');
 WHEN C_INTEGER_DATATYPE   THEN l_source  := REPLACE(l_source,'$type$'  ,'Num');
 ELSE
    l_source:= NULL;
    l_error_message:= 'Invalid datatype '||p_rec_sources.array_datatype_code(p_Index)
                    ||' for the system source code '
                    ||p_rec_sources.array_source_code(p_Index);
    RAISE invalid_source;
END CASE;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetSystemSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||l_error_message
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetSystemSource');
END GetSystemSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetCustomSource                                         |
|                                                           |
|  It generates the call to custom sources in AAD packages  |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GetCustomSource(
    p_Index                        IN  BINARY_INTEGER
  , p_rec_sources                  IN  OUT NOCOPY t_rec_sources
  , p_variable                     IN  VARCHAR2 DEFAULT NULL
 )
RETURN VARCHAR2
IS
CURSOR source_cur ( p_source_code            VARCHAR2
                  , p_source_type_code       VARCHAR2
                  , p_source_application_id  NUMBER)
IS
SELECT DISTINCT
       xsp.ref_source_application_id
     , xsp.ref_source_type_code
     , xsp.ref_source_code
     , xsp.parameter_type_code
     , xsp.constant_value
     , xsp.user_sequence
FROM   xla_source_params     xsp
WHERE  xsp.source_code         = p_source_code
   AND xsp.source_type_code    = p_source_type_code
   AND xsp.application_id      = p_source_application_id
ORDER BY user_sequence
;

l_source                VARCHAR2(32000);
l_parms                 VARCHAR2(32000);
l_first                 BOOLEAN;
l_Idx                   BINARY_INTEGER;
l_rec_sources           t_rec_sources;
l_error_message         VARCHAR2(4000);
invalid_source          EXCEPTION;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetCustomSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rec_sources := p_rec_sources;
l_source      := NULL;
l_parms       := NULL;

IF NOT l_rec_sources.array_source_code.EXISTS(p_Index) OR
    l_rec_sources.array_source_code(p_Index) IS NULL THEN
   l_error_message := 'Source Index '||p_Index||' does not exist in the source cache';
   RAISE invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||l_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||l_rec_sources.array_application_id(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF l_rec_sources.array_plsql_function(p_Index) IS NOT NULL THEN

   l_first := TRUE;

   FOR source_rec IN  source_cur(
         p_source_code           => l_rec_sources.array_source_code(p_Index)
       , p_source_type_code      => l_rec_sources.array_source_type_code(p_Index)
       , p_source_application_id => l_rec_sources.array_application_id(p_Index)
                             )
    LOOP

        IF l_first THEN
           l_parms := l_parms || g_chr_newline;
           l_first := FALSE;
        ELSE
           l_parms := l_parms || g_chr_newline ||', ';
        END IF;

        IF source_rec.parameter_type_code IN (C_NUMBER_DATATYPE ,
                                              C_INTEGER_DATATYPE,
                                              C_FLEXFIELD_DATATYPE) THEN

          l_parms := l_parms || source_rec.constant_value ;

        ELSIF source_rec.parameter_type_code = C_DATE_DATATYPE THEN

          l_parms := l_parms || 'fnd_date.canonical_to_date('''||source_rec.constant_value ||''')';

        ELSIF source_rec.parameter_type_code = C_CHAR_DATATYPE THEN

          l_parms := l_parms || ''''||REPLACE(source_rec.constant_value,'''','''''')|| '''';

        ELSIF source_rec.parameter_type_code ='S' OR
             (source_rec.parameter_type_code = 'Y' AND
              source_rec.ref_source_application_id =602)  THEN

          l_Idx := CacheSource (
                     p_source_code           => source_rec.ref_source_code
                   , p_source_type_code      => source_rec.ref_source_type_code
                   , p_source_application_id => source_rec.ref_source_application_id
                   , p_rec_sources           => l_rec_sources
                    );

          l_parms := l_parms || GenerateSource(
                                 p_Index           => l_Idx
                               , p_rec_sources     => l_rec_sources
                               , p_variable        => p_variable
                               , p_translated_flag => 'N'
                              );
        END IF;
    END LOOP;

   l_source  := l_rec_sources.array_plsql_function(p_Index);
   IF l_parms IS NOT NULL THEN
      l_source := l_source ||'('|| l_parms|| ')';
   END IF;

ELSE
   l_error_message := 'Invalid custom source definition= '||
                      ' - source code = '||l_rec_sources.array_source_code(p_Index)||
                      ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                      ' - source application id = '||l_rec_sources.array_application_id(p_Index);
   RAISE invalid_source;
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_rec_sources := l_rec_sources;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetCustomSource');
END GetCustomSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetValueSetSource                                       |
|                                                           |
|  It generates the call to custom sources in AAD packages  |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GetValueSetSource(
     p_Index                        IN  BINARY_INTEGER
   , p_rec_sources                  IN  OUT NOCOPY t_rec_sources
   , p_variable                     IN VARCHAR2 DEFAULT NULL
   , p_translated_flag              IN VARCHAR2 DEFAULT NULL
 )
RETURN VARCHAR2
IS

C_VALUE_SET                   CONSTANT     VARCHAR2(10000) := '
GetMeaning (
  p_flex_value_set_id        => $flex_value_set_id$
, p_flex_value               => TO_CHAR($source$)
, p_source_code              => ''$source_code$''
, p_source_type_code         => ''$source_type_code$''
, p_source_application_id    => $source_application_id$
)
';

l_source                VARCHAR2(32000);
l_rec_sources           t_rec_sources;
l_error_message         VARCHAR2(4000);
invalid_source          EXCEPTION;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetValueSetSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetValueSetSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rec_sources := p_rec_sources;
l_source      := NULL;

IF  NOT l_rec_sources.array_source_code.EXISTS(p_Index) OR
     l_rec_sources.array_source_code(p_Index) IS NULL THEN
     l_error_message := 'Source Index '||p_Index||' does not exist in the source cache';
     RAISE invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||l_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||l_rec_sources.array_application_id(p_Index)||
                        ' - flex_value_set_id = ' ||l_rec_sources.array_flex_value_set_id(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (NVL(p_translated_flag,'N') = 'Y' ) THEN

  -- get source meaning
  l_source    := C_VALUE_SET ;
  l_source    := REPLACE(l_source,'$flex_value_set_id$',
                       l_rec_sources.array_flex_value_set_id(p_Index));
  l_source    := REPLACE(l_source,'$source_code$',
                       l_rec_sources.array_source_code(p_Index));
  l_source    := REPLACE(l_source,'$source_type_code$',
                       l_rec_sources.array_source_type_code(p_Index));
  l_source    := REPLACE(l_source,'$source_application_id$',
                       l_rec_sources.array_application_id(p_Index));

ELSE --  get source code
  l_source    := '$source$';
END IF;


CASE l_rec_sources.array_source_type_code(p_Index)

    WHEN C_CUSTOM_SOURCE_TYPE THEN

        l_source    := REPLACE(l_source,'$source$',
                               GetCustomSource(
                                  p_Index
                                , l_rec_sources
                                , p_variable
                                ));

    WHEN C_SEEDED_SOURCE_TYPE THEN

       l_source    := REPLACE(l_source,'$source$',
                             GetStandardSource(
                                 p_Index
                               , l_rec_sources.array_source_code
                               , l_rec_sources.array_datatype_code
                               , p_variable
                                ));

    WHEN  C_SYSTEM_SOURCE_TYPE THEN

       l_source :=REPLACE(l_source,'$source$',
                               GetSystemSource(
                                 p_Index
                               , l_rec_sources
                                ));

    ELSE

       l_source    := NULL;
       l_error_message:= SUBSTR('Invalid source type code '
                            ||l_rec_sources.array_source_type_code(p_Index)
                            ||' defined for source '
                            ||l_rec_sources.array_source_code(p_Index),1,4000);

       RAISE invalid_source;
END CASE;

l_source  := REPLACE(l_source,'$source_name$',
                  REPLACE(l_rec_sources.array_source_name(p_Index),'''',''''''));
l_source  := REPLACE(l_source,'$product_name$',
                  xla_cmp_pad_pkg.GetApplicationName (l_rec_sources.array_application_id(p_Index)));

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
       (p_msg      => 'END of GetValueSetSource'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);

END IF;
p_rec_sources := l_rec_sources;
RETURN l_source;
EXCEPTION
    WHEN invalid_source THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetValueSetSource');
END GetValueSetSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetLookupSource                                         |
|                                                           |
|  It generates the call to lookup sources in AAD packages  |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GetLookupSource(
         p_Index                        IN BINARY_INTEGER
       , p_rec_sources                  IN  OUT NOCOPY t_rec_sources
       , p_variable                     IN VARCHAR2 DEFAULT NULL
       , p_translated_flag              IN VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS
C_LOOKUP_SOURCE           CONSTANT     VARCHAR2(10000) := '
xla_ae_sources_pkg.GetLookupMeaning(
  p_lookup_code            => TO_CHAR($source$)
, p_lookup_type            => ''$lookup_code$''
, p_view_application_id    => $view_application_id$
, p_source_code            => ''$source_code$''
, p_source_type_code       => ''$source_type_code$''
, p_source_application_id  => $source_application_id$
)
';
--
C_LOOKUP_MEANING          CONSTANT     VARCHAR2(10000) := '
ValidateLookupMeaning(
  p_meaning                => $source_meaning$
, p_lookup_code            => TO_CHAR($source$)
, p_lookup_type            => ''$lookup_code$''
, p_source_code            => ''$source_code$''
, p_source_type_code       => ''$source_type_code$''
, p_source_application_id  => $source_application_id$
)
';

l_source                VARCHAR2(32000);
l_rec_sources           t_rec_sources;
invalid_source          EXCEPTION;
l_error_message         VARCHAR2(4000);
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLookupSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetLookupSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
l_rec_sources := p_rec_sources;
l_source      := NULL;

IF   NOT l_rec_sources.array_source_code.EXISTS(p_Index) OR
     l_rec_sources.array_source_code(p_Index)  IS NULL THEN
     l_error_message := 'Source Index :'||p_Index||' does not exist in the source cache';
    RAISE invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||l_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||l_rec_sources.array_application_id(p_Index)||
                        ' - lookup code='||l_rec_sources.array_lookup_type(p_Index)||
                        ' - view application id='||l_rec_sources.array_view_application_id(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF ( NVL(p_translated_flag,'N') = 'Y' )
THEN

   CASE l_rec_sources.array_source_type_code(p_Index)

   WHEN C_SEEDED_SOURCE_TYPE THEN

     l_source    := C_LOOKUP_MEANING ;

     l_source    := REPLACE(l_source,'$source$',
                             GetStandardSource(
                              p_Index
                            , l_rec_sources.array_source_code
                            , l_rec_sources.array_datatype_code
                            , p_variable
                            ));

     l_source    := REPLACE(l_source,'$source_meaning$',
                            GetMeaningSource(
                              p_Index
                            , l_rec_sources.array_source_code
                            , p_variable
                             ));

   WHEN C_CUSTOM_SOURCE_TYPE THEN

    l_source    := C_LOOKUP_SOURCE ;

    l_source    := REPLACE(l_source,'$source$',
                            GetCustomSource(
                              p_Index
                            , l_rec_sources
                            , p_variable
                             ));

  WHEN C_SYSTEM_SOURCE_TYPE THEN

        l_source    := C_LOOKUP_SOURCE ;

          l_source :=REPLACE(l_source,'$source$',
                             GetSystemSource(
                                p_Index
                              , l_rec_sources
                              ));
  ELSE
      l_error_message:= SUBSTR('Invalid source type code '
                            ||l_rec_sources.array_source_type_code(p_Index)
                            ||' defined for source '
                            ||l_rec_sources.array_source_code(p_Index),1,4000);
      RAISE invalid_source;
  END CASE;

  l_source  := REPLACE(l_source,'$lookup_code$'          ,
                l_rec_sources.array_lookup_type(p_Index));
  l_source  := REPLACE(l_source,'$view_application_id$'  ,
                l_rec_sources.array_view_application_id(p_Index));
  l_source  := REPLACE(l_source,'$source_code$'          ,
                l_rec_sources.array_source_code(p_Index));
  l_source  := REPLACE(l_source,'$source_type_code$'     ,
                l_rec_sources.array_source_type_code(p_Index));
  l_source  := REPLACE(l_source,'$source_application_id$',
                l_rec_sources.array_application_id(p_Index));

ELSE

CASE l_rec_sources.array_source_type_code(p_Index)
    WHEN C_CUSTOM_SOURCE_TYPE THEN

          l_source    :=  GetCustomSource(
                                  p_Index
                                , l_rec_sources
                                , p_variable
                                );

    WHEN C_SEEDED_SOURCE_TYPE THEN

         l_source    :=  GetStandardSource(
                              p_Index
                            , l_rec_sources.array_source_code
                            , l_rec_sources.array_datatype_code
                            , p_variable
                         );


    WHEN C_SYSTEM_SOURCE_TYPE THEN

           l_source    :=  GetSystemSource(
                                p_Index
                              , l_rec_sources
                              );

   ELSE
     l_error_message:= SUBSTR('Invalid source type code '
                            ||l_rec_sources.array_source_type_code(p_Index)
                            ||' defined for source '
                            ||l_rec_sources.array_source_code(p_Index),1,4000);

     RAISE invalid_source;
   END CASE;

   l_source  := REPLACE(l_source,'$source_name$',
         REPLACE(l_rec_sources.array_source_name(p_Index),'''',''''''));
   l_source  := REPLACE(l_source,'$product_name$',
        xla_cmp_pad_pkg.GetApplicationName (l_rec_sources.array_application_id(p_Index)));
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'END of GetLookupSource'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

END IF;
p_rec_sources := l_rec_sources;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RETURN 'NULL';
   WHEN xla_exceptions_pkg.application_exception   THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetLookupSource');
END GetLookupSource;

/*----------------------------------------------------------+
| Private function                                          |
|                                                           |
|   GetKeyFlexfieldSource                                   |
|                                                           |
|  It generates the call to key flexfield sources in AAD    |
|  packages                                                 |
|                                                           |
+----------------------------------------------------------*/
--
FUNCTION GetKeyFlexfieldSource  (
   p_Index                        IN BINARY_INTEGER
 , p_rec_sources                  IN OUT NOCOPY t_rec_sources
 , p_variable                     IN VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS

C_KEY_FLEXFIELD          CONSTANT     VARCHAR2(1000) :=
 'TO_NUMBER($source$)'
;

C_KEY_FLEXFIELD_SEGMENT   CONSTANT     VARCHAR2(1000) :=
 'TO_CHAR($source$)'
;

l_source                VARCHAR2(32000);
l_rec_sources           t_rec_sources;
l_error_message         VARCHAR2(4000);
invalid_source          EXCEPTION;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetKeyFlexfieldSource';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetKeyFlexfieldSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
l_rec_sources := p_rec_sources;
l_source      := NULL;

IF NOT l_rec_sources.array_source_code.EXISTS(p_Index) OR
   l_rec_sources.array_source_code(p_Index) IS NULL  THEN
     l_error_message := 'Source Index :'||p_Index||' does not exist in the source cache';
     raise invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||l_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||l_rec_sources.array_application_id(p_Index) ||
                        ' - key_flexfield_flag = '||l_rec_sources.array_key_flexfield_flag(p_Index) ||
                        ' - flexfield_appl_id = '||l_rec_sources.array_flexfield_appl_id(p_Index)||
                        ' - id_flex_code = '||l_rec_sources.array_id_flex_code(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

CASE l_rec_sources.array_datatype_code(p_Index)
    WHEN  C_NUMBER_DATATYPE THEN l_source   := C_KEY_FLEXFIELD ;
    WHEN 'I'                THEN l_source   := C_KEY_FLEXFIELD ;
    WHEN 'F'                THEN l_source   := C_KEY_FLEXFIELD ;
    WHEN C_CHAR_DATATYPE    THEN l_source   := C_KEY_FLEXFIELD_SEGMENT ;
ELSE
      l_error_message := 'Invalid key flexfield source data type :'
                         ||l_rec_sources.array_datatype_code(p_Index);

      RAISE invalid_source;
END CASE;

CASE l_rec_sources.array_source_type_code(p_Index)

       WHEN C_SEEDED_SOURCE_TYPE THEN
            l_source    := REPLACE(l_source,'$source$',
                              GetStandardSource(
                                  p_Index
                                , l_rec_sources.array_source_code
                                , l_rec_sources.array_datatype_code
                                , p_variable
                                ));
       WHEN C_CUSTOM_SOURCE_TYPE THEN
            l_source    := REPLACE(l_source,'$source$',
                              GetCustomSource(
                                   p_Index
                                 , l_rec_sources
                                 , p_variable
	                          ));

      WHEN C_SYSTEM_SOURCE_TYPE THEN
            l_source :=REPLACE(l_source,'$source$',
                          GetSystemSource(
                             p_Index
                           , l_rec_sources
                          ));
      ELSE

           l_error_message:= SUBSTR('Invalid source type code '
                            ||l_rec_sources.array_source_type_code(p_Index)
                            ||' defined for source '
                            ||l_rec_sources.array_source_code(p_Index),1,1000);

           RAISE invalid_source;
END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => 'END of GetKeyFlexfieldSource'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;
p_rec_sources := l_rec_sources;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RETURN 'NULL';
   WHEN xla_exceptions_pkg.application_exception   THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetKeyFlexfieldSource');
END GetKeyFlexfieldSource ;


/*----------------------------------------------------------+
| Public function                                           |
|                                                           |
|   GenerateSource                                          |
|                                                           |
|  It drives the generation of the sources in the AAD       |
|  packages.                                                |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GenerateSource(
       p_Index                        IN  BINARY_INTEGER
     , p_rec_sources                  IN OUT NOCOPY t_rec_sources
     , p_variable                     IN VARCHAR2 DEFAULT NULL
     , p_translated_flag              IN VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS
l_source                VARCHAR2(32000);
l_rec_sources           t_rec_sources;
l_error_message         VARCHAR2(4000);
invalid_source          EXCEPTION;
l_log_module            VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_rec_sources := p_rec_sources;
l_source      := NULL;

IF NOT l_rec_sources.array_source_code.EXISTS(p_Index)   OR
   l_rec_sources.array_source_code(p_Index)      IS NULL OR
   l_rec_sources.array_source_type_code(p_Index) IS NULL OR
   l_rec_sources.array_application_id(p_Index)  IS NULL
   THEN
     l_error_message := 'Source Index :'||p_Index||' does not exist in the source cache';
     RAISE invalid_source;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' source code = '||l_rec_sources.array_source_code(p_Index)||
                        ' - source type code = '||l_rec_sources.array_source_type_code(p_Index)||
                        ' - source application id = '||l_rec_sources.array_application_id(p_Index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


IF    l_rec_sources.array_flex_value_set_id(p_Index)   IS NOT NULL THEN

              l_source :=GetValueSetSource(
                              p_Index
                            , l_rec_sources
                            , p_variable
                            , p_translated_flag
                           ) ;


ELSIF l_rec_sources.array_lookup_type(p_Index)         IS NOT NULL AND
      l_rec_sources.array_view_application_id(p_Index) IS NOT NULL THEN

             l_source := GetLookupSource(
                             p_Index
                           , l_rec_sources
                           , p_variable
                           , p_translated_flag
                          );


ELSIF nvl(l_rec_sources.array_key_flexfield_flag(p_Index),'N') ='Y' AND
      l_rec_sources.array_flexfield_appl_id(p_Index)    IS NOT NULL AND
      l_rec_sources.array_id_flex_code(p_Index)         IS NOT NULL THEN


             l_source := GetKeyFlexfieldSource(
                             p_Index
                           , l_rec_sources
                           , p_variable
                          );


ELSIF l_rec_sources.array_source_type_code(p_Index)  = C_SEEDED_SOURCE_TYPE   THEN

             l_source :=GetStandardSource(
                             p_Index
                           , l_rec_sources.array_source_code
                           , l_rec_sources.array_datatype_code
                           , p_variable
                         );


ELSIF l_rec_sources.array_source_type_code(p_Index)  = C_SYSTEM_SOURCE_TYPE   THEN

               l_source :=GetSystemSource(
                             p_Index
                           , l_rec_sources
                          );


-- custom source
ELSIF l_rec_sources.array_source_type_code(p_Index)    = C_CUSTOM_SOURCE_TYPE THEN
      l_source := GetCustomSource(
                               p_Index
                             , l_rec_sources
                             , p_variable
                             );

ELSE
   l_error_message:= SUBSTR('Invalid Definition for source code: '
                            ||l_rec_sources.array_source_code(p_Index)
                            ||' and source type: '
                            ||l_rec_sources.array_source_type_code(p_Index),1,1000);
   RAISE invalid_source;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

        trace
           (p_msg      => 'END of GenerateSource'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

END IF;
p_rec_sources := l_rec_sources;
RETURN l_source;
EXCEPTION
   WHEN invalid_source THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
      RETURN 'NULL';
   WHEN xla_exceptions_pkg.application_exception   THEN
      p_rec_sources := l_rec_sources;
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GenerateSource');
END GenerateSource;


/*----------------------------------------------------------+
| Public function                                           |
|                                                           |
|   GenerateParameters                                      |
|                                                           |
|  It generates the AAD procedures/functions parameters:    |
|  p_sourc_1 IN VARCHAR2, p_source_2 IN NUMBER, .....       |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GenerateParameters   (
    p_array_source_index  IN t_array_ByInt
  , p_rec_sources         IN t_rec_sources
 )
RETURN VARCHAR2
IS
C_PARAMETER      CONSTANT VARCHAR2(1000):= ' , p_source_$Index$            IN $datatype$';
C_MNG_PARAMETER  CONSTANT VARCHAR2(1000):= ' , p_source_$Index$_meaning    IN VARCHAR2';
l_parameters              VARCHAR2(32000);
l_one_parameter           VARCHAR2(32000);
l_error_message           VARCHAR2(4000);
l_log_module              VARCHAR2(240);
invalid_source            EXCEPTION;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateParameters';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateParameters = '||p_array_source_index.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_parameters    := NULL;

IF p_array_source_index.COUNT > 0   THEN

  FOR Idx IN p_array_source_index.FIRST .. p_array_source_index.LAST LOOP

    IF p_array_source_index.EXISTS(Idx) THEN

       IF NOT p_rec_sources.array_source_code.EXISTS(Idx) THEN

         l_error_message:= SUBSTR('Source does not exist in the cache : '||Idx, 1,1000);
         RAISE invalid_source;

       ELSIF  p_rec_sources.array_source_code(Idx) IS NULL OR
              p_rec_sources.array_source_type_code(Idx) <> 'S' OR
              p_rec_sources.array_datatype_code(Idx) IS NULL THEN

          l_error_message:= SUBSTR('Invalid source: '||Idx
                            ||' - '||p_rec_sources.array_source_code(Idx)
                            ||' - '||p_rec_sources.array_source_type_code(Idx)
                            ||' - '||p_rec_sources.array_datatype_code(Idx),1,1000);

          RAISE invalid_source;

       END IF;

       l_one_parameter := null;
       -- display source_name as a comment
       IF p_rec_sources.array_source_name.EXISTS(Idx) AND
          p_rec_sources.array_source_name(Idx) IS NOT NULL
       THEN
          l_one_parameter := l_one_parameter ||'--'||p_rec_sources.array_source_name(Idx) ;
       END IF;

       l_one_parameter  := l_one_parameter ||g_chr_newline || C_PARAMETER ;

       --If compiling for an AAD generate also the meaning parameter
       IF g_component_type = 'TAB_ADR'
       THEN
          NULL;
       ELSE --lookup source
          IF p_rec_sources.array_lookup_type.EXISTS(Idx)              AND
             p_rec_sources.array_lookup_type(Idx)         IS NOT NULL AND
             p_rec_sources.array_view_application_id.EXISTS(Idx)      AND
             p_rec_sources.array_view_application_id(Idx) IS NOT NULL
          THEN
            l_one_parameter  := l_one_parameter|| g_chr_newline || C_MNG_PARAMETER;

          END IF;
       END IF;

       l_one_parameter  := REPLACE(l_one_parameter,'$Index$',Idx);

       l_one_parameter  := REPLACE(l_one_parameter,'$datatype$',
                                  GetDataType(p_rec_sources.array_datatype_code(Idx)));
       l_parameters := l_parameters || g_chr_newline || l_one_parameter;
    --
    END IF;
END LOOP;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_parameters;
EXCEPTION
    WHEN invalid_source  THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
           trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||l_error_message
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
         END IF;
        RETURN NULL;
    WHEN VALUE_ERROR THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
      END IF;
      RAISE;
 WHEN xla_exceptions_pkg.application_exception   THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
     END IF;
     RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GenerateParameters ');
END GenerateParameters;

/*----------------------------------------------------------+
| Public function                                           |
|                                                           |
|   get_obj_parm_for_tab                                    |
|                                                           |
|  It generates the AAD procedures/functions parameters:    |
|  p_sourc_1 IN VARCHAR2, p_source_2 IN NUMBER, .....       |
|                                                           |
|  Note that this function is used only for TAB             |
+----------------------------------------------------------*/

FUNCTION get_obj_parm_for_tab   (
    p_array_source_index           IN t_array_ByInt
  , p_rec_sources                  IN t_rec_sources
 )
RETURN VARCHAR2
IS
l_return_value           VARCHAR2(32767);
l_log_module             VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_obj_parm_for_tab';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   --Set the global variable to component type TAD_ADR
   g_component_type := 'TAB_ADR';

   l_return_value := GenerateParameters
                      (
                       p_array_source_index  => p_array_source_index
                      ,p_rec_sources         => p_rec_sources
                     );


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_return_value;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.get_obj_parm_for_tab ');
END get_obj_parm_for_tab;

--
--===========================================================================
--
--
--
--
--
--       Procedures and functions to cache source definitions and
--       to index each sources defined in a AAD.
--
--
--
--
--
--===========================================================================

/*--------------------------------------------------------------+
| Private function                                              |
|                                                               |
|   IsSourceInCache                                             |
|                                                               |
|   Boolean function returns TRUE, if the source exists in the  |
|   source cache, otherwise FALSE. It also returns the position |
|   where the source is cached                                  |
+--------------------------------------------------------------*/

FUNCTION IsSourceInCache(
   p_source_code              IN VARCHAR2
 , p_source_type_code         IN VARCHAR2
 , p_source_application_id    IN NUMBER
 , p_rec_sources              IN t_rec_sources
 , p_position                OUT NOCOPY BINARY_INTEGER
)
RETURN BOOLEAN
IS
l_position           BINARY_INTEGER;
l_exist              BOOLEAN;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.IsSourceInCache';
END IF;

l_position    := 1;
l_exist       := FALSE;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

        trace
         (p_msg      => ' p_source_code = '||p_source_code||
                        ',p_source_type_code = '||p_source_type_code||
                        ',p_source_application_id = '||p_source_application_id||
                        ',number of sources in cache = '||p_rec_sources.array_source_code.COUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

WHILE NOT l_exist AND l_position <= p_rec_sources.array_source_code.COUNT        LOOP

   IF p_rec_sources.array_source_code.EXISTS(l_position)                          AND
      p_rec_sources.array_source_code(l_position)       = p_source_code           AND
      p_rec_sources.array_source_type_code(l_position)  = p_source_type_code      AND
      p_rec_sources.array_application_id(l_position)    = p_source_application_id
   THEN
     l_exist   := TRUE;
   ELSE
     l_position := l_position + 1;
   END IF;

END LOOP;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

        trace
         (p_msg      => ' l_exist = '||CASE l_exist
                                        WHEN TRUE THEN 'TRUE'
                                        ELSE 'FALSE'
                                       END ||
                        ' , position = '||l_position
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
p_position := l_position;
RETURN l_exist;
EXCEPTION
WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
   END IF;
   RETURN FALSE;
END IsSourceInCache;

/*--------------------------------------------------------------+
| Private function                                              |
|                                                               |
|   CacheCustomSource                                           |
|                                                               |
|   Caches the sources assigned to Customer source              |
+--------------------------------------------------------------*/

PROCEDURE CacheCustomSource (
   p_source_code                  IN VARCHAR2
 , p_source_type_code             IN VARCHAR2
 , p_source_application_id        IN NUMBER
 , p_rec_sources                  IN OUT NOCOPY t_rec_sources
)
IS
CURSOR source_cur ( p_source_code            VARCHAR2
                  , p_source_type_code       VARCHAR2
                  , p_source_application_id  NUMBER) IS
SELECT DISTINCT
       xsp.ref_source_application_id
     , xsp.ref_source_type_code
     , xsp.ref_source_code
FROM   xla_source_params       xsp
WHERE  xsp.source_code         = p_source_code
   AND xsp.source_type_code    = p_source_type_code
   AND xsp.application_id      = p_source_application_id
   AND xsp.parameter_type_code = 'S'             --not constant
   AND xsp.ref_source_application_id   IS NOT NULL
   AND xsp.ref_source_type_code        IS NOT NULL
   AND xsp.ref_source_code             IS NOT NULL
;
--
source_rec           source_cur%ROWTYPE;
l_position           BINARY_INTEGER;
l_log_module         VARCHAR2(240);
l_rec_sources        t_rec_sources;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CacheCustomSource';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CacheCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_rec_sources  := p_rec_sources;

FOR source_rec IN  source_cur(
         p_source_code           => p_source_code
       , p_source_type_code      => p_source_type_code
       , p_source_application_id => p_source_application_id
                             )
LOOP
   --
   l_position :=  CacheSource (
                p_source_code           => source_rec.ref_source_code
              , p_source_type_code      => source_rec.ref_source_type_code
              , p_source_application_id => source_rec.ref_source_application_id
              , p_rec_sources           => l_rec_sources
             );

END LOOP;

p_rec_sources  := l_rec_sources;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CacheCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
        p_rec_sources  := l_rec_sources;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN OTHERS    THEN
      IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
      p_rec_sources  := l_rec_sources;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.CacheCustomSource');
END CacheCustomSource;

/*--------------------------------------------------------------+
| Public function                                               |
|                                                               |
|   CacheCustomSource                                           |
|                                                               |
|   Caches the source definitions in the p_rec_sources cache    |
+--------------------------------------------------------------*/

FUNCTION CacheSource (
    p_source_code                  IN VARCHAR2
  , p_source_type_code             IN VARCHAR2
  , p_source_application_id        IN NUMBER
  , p_rec_sources                  IN OUT NOCOPY t_rec_sources
  )
RETURN BINARY_INTEGER
IS
l_exists             BOOLEAN;
l_position           BINARY_INTEGER;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CacheSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CacheSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => ' p_source_code = '||p_source_code||
                        ' - p_source_type_code = '||p_source_type_code||
                        ' - p_source_application_id = '||p_source_application_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_exists := IsSourceInCache(
                p_source_code
              , p_source_type_code
              , p_source_application_id
              , p_rec_sources
              , l_position) ;

IF NOT l_exists THEN

   -- cache source definition
         SELECT  DISTINCT
                 xsb.source_code
               , xsb.source_type_code
               , xsb.application_id
               , xst.name
               , xsb.datatype_code
               , xsb.plsql_function_name
               , xsb.flex_value_set_id
               , xsb.translated_flag
               , xsb.lookup_type
               , xsb.view_application_id
               , xsb.key_flexfield_flag
               , xsb.flexfield_application_id
               , DECODE (xsb.flexfield_application_id
                          , NULL,  NULL
                          , fnd.application_short_name )
               , xsb.id_flex_code
               , xsb.segment_code

         INTO  p_rec_sources.array_source_code(l_position)
             , p_rec_sources.array_source_type_code(l_position)
             , p_rec_sources.array_application_id(l_position)
             , p_rec_sources.array_source_name(l_position)
             , p_rec_sources.array_datatype_code(l_position)
             , p_rec_sources.array_plsql_function(l_position)
             , p_rec_sources.array_flex_value_set_id(l_position)
             , p_rec_sources.array_translated_flag(l_position)
             , p_rec_sources.array_lookup_type(l_position)
             , p_rec_sources.array_view_application_id(l_position)
             , p_rec_sources.array_key_flexfield_flag(l_position)
             , p_rec_sources.array_flexfield_appl_id(l_position)
             , p_rec_sources.array_appl_short_name(l_position)
             , p_rec_sources.array_id_flex_code(l_position)
             , p_rec_sources.array_segment_code (l_position)
         FROM   xla_sources_b   xsb
              , xla_sources_tl  xst
              , fnd_application fnd
         WHERE  xsb.source_code         = p_source_code
            AND xsb.source_type_code    = p_source_type_code
            AND xsb.application_id      = p_source_application_id
            AND xsb.source_code         = xst.source_code
            AND xsb.source_type_code    = xst.source_type_code
            AND xsb.application_id      = xst.application_id (+)
            AND xst.language         (+)= USERENV('LANG')
            AND xsb.enabled_flag        = 'Y'
            AND nvl(xsb.flexfield_application_id,p_source_application_id) = fnd.application_id (+)
         ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => 'Cached in '||l_position||
                        ' : p_source_code = '||p_rec_sources.array_source_code(l_position)||
                        ',p_source_type_code = '||p_rec_sources.array_source_type_code(l_position)||
                        ',p_source_application_id = '||p_rec_sources.array_application_id(l_position) ||
                        ', name ='||p_rec_sources.array_source_name(l_position)||
                        ',datatype_code= '||p_rec_sources.array_datatype_code(l_position)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

       trace
         (p_msg      => ' lookup_type= '||p_rec_sources.array_lookup_type(l_position)||
                        ',view_application_id= '||p_rec_sources.array_view_application_id(l_position)||
                        ',flex_value_set_id= '||p_rec_sources.array_flex_value_set_id(l_position)||
                        ',key_flexfield_flag= '||p_rec_sources.array_key_flexfield_flag(l_position)||
                        ',flexfield_application_id='|| p_rec_sources.array_flexfield_appl_id(l_position)||
                        ',appl_short_name ='||p_rec_sources.array_appl_short_name(l_position) ||
                        ',id_flex_code='||p_rec_sources.array_id_flex_code(l_position) ||
                        ',segment_code='||p_rec_sources.array_segment_code (l_position)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;

    -- cache source defined in custom source
   IF p_source_type_code = C_CUSTOM_SOURCE_TYPE THEN

       CacheCustomSource (
                             p_source_code                  => p_source_code
                           , p_source_type_code             => p_source_type_code
                           , p_source_application_id        => p_source_application_id
                           , p_rec_sources                  => p_rec_sources
                            );
   END IF;

ELSE
  null;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => 'Exist in ='||l_position
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CacheSource '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_position;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN TOO_MANY_ROWS THEN
    IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN xla_exceptions_pkg.application_exception   THEN

        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN OTHERS    THEN

      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.CacheSource');
END CacheSource;

/*--------------------------------------------------------------+
| Private function                                              |
|                                                               |
|   StackCustomSource                                           |
|                                                               |
|   Caches the custom source in the p_array_source_index cache  |
+--------------------------------------------------------------*/
PROCEDURE StackCustomSource (
   p_source_code                  IN VARCHAR2
 , p_source_type_code             IN VARCHAR2
 , p_source_application_id        IN NUMBER
 , p_array_source_index           IN OUT NOCOPY t_array_ByInt
 , p_rec_sources                  IN OUT NOCOPY t_rec_sources
)
IS
--
CURSOR source_cur ( p_source_code            VARCHAR2
                  , p_source_type_code       VARCHAR2
                  , p_source_application_id  NUMBER)
IS
SELECT DISTINCT
       xsp.ref_source_application_id
     , xsp.ref_source_type_code
     , xsp.ref_source_code
FROM   xla_source_params     xsp
WHERE  xsp.source_code         = p_source_code
   AND xsp.source_type_code    = p_source_type_code
   AND xsp.application_id      = p_source_application_id
   AND xsp.parameter_type_code = 'S'
   AND xsp.ref_source_application_id IS NOT NULL
   AND xsp.ref_source_type_code IS NOT NULL
   AND xsp.ref_source_code IS NOT NULL
;
--
source_rec           source_cur%ROWTYPE;
l_position           BINARY_INTEGER;
l_rec_sources        t_rec_sources;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.StackCustomSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of StackCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_rec_sources := p_rec_sources;

FOR source_rec IN  source_cur(
         p_source_code           => p_source_code
       , p_source_type_code      => p_source_type_code
       , p_source_application_id => p_source_application_id )
LOOP

   l_position:=  StackSource(
       p_source_code            => source_rec.ref_source_code
     , p_source_type_code       => source_rec.ref_source_type_code
     , p_source_application_id  => source_rec.ref_source_application_id
     , p_array_source_index     => p_array_source_index
     , p_rec_sources            => l_rec_sources
     );

END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of StackCustomSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
p_rec_sources := l_rec_sources;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
        p_rec_sources := l_rec_sources;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN OTHERS    THEN
      IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
      p_rec_sources := l_rec_sources;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.StackCustomSource');
END StackCustomSource;

/*--------------------------------------------------------------+
| Public function                                               |
|                                                               |
|   StackSource                                                 |
|                                                               |
|    Caches the source in the p_array_source_index cache        |
+--------------------------------------------------------------*/

FUNCTION StackSource(
    p_source_code                  IN VARCHAR2
  , p_source_type_code             IN VARCHAR2
  , p_source_application_id        IN NUMBER
  , p_array_source_index           IN OUT NOCOPY t_array_ByInt
  , p_rec_sources                  IN OUT NOCOPY t_rec_sources
  )
RETURN BINARY_INTEGER
IS
l_position             BINARY_INTEGER;
l_rec_sources          t_rec_sources;
l_array_source_index   t_array_ByInt;
l_log_module           VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.StackSource';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of StackSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Stack up : p_source_code = '||p_source_code||
                        ' - p_source_type_code = '||p_source_type_code||
                        ' - p_source_application_id = '||p_source_application_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_rec_sources        := p_rec_sources;
l_array_source_index := p_array_source_index;

l_position :=  CacheSource (
               p_source_code           => p_source_code
             , p_source_type_code      => p_source_type_code
             , p_source_application_id => p_source_application_id
             , p_rec_sources           => l_rec_sources
            );

CASE  p_source_type_code

     WHEN C_SEEDED_SOURCE_TYPE  THEN  l_array_source_index(l_position):= l_position;
     WHEN C_SYSTEM_SOURCE_TYPE  THEN  null;
     WHEN C_CUSTOM_SOURCE_TYPE  THEN

       StackCustomSource (
                      p_source_code           => p_source_code
                    , p_source_type_code      => p_source_type_code
                    , p_source_application_id => p_source_application_id
                    , p_array_source_index    => l_array_source_index
                    , p_rec_sources           => l_rec_sources
                   );
     ELSE null;

END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of StackSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

p_rec_sources        := l_rec_sources;
p_array_source_index := l_array_source_index;
RETURN l_position;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_rec_sources        := l_rec_sources;
        p_array_source_index := l_array_source_index;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      p_rec_sources        := l_rec_sources;
      p_array_source_index := l_array_source_index;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.StackSource');
END StackSource;

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                      cache AMB Objects/ AMB Entity Dico                  |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

/*--------------------------------------------------------------+
| Private function                                              |
|                                                               |
|    IsObjectInAADCache                                         |
|                                                               |
|    Boolean function returns TRUE if the object exists in the  |
|    AMB objects cache, FALSE otherwise. It also returns the    |
|    object position in the cache                               |
+--------------------------------------------------------------*/

FUNCTION IsObjectInAADCache (
    p_object                       IN VARCHAR2
  , p_object_code                  IN VARCHAR2
  , p_object_type_code             IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_event_class_code             IN VARCHAR2
  , p_event_type_code              IN VARCHAR2
  , p_line_definition_code         IN VARCHAR2
  , p_line_definition_owner_code   IN VARCHAR2
  , p_rec_aad_objects              IN t_rec_aad_objects
  , p_position                     OUT NOCOPY BINARY_INTEGER
)
RETURN BOOLEAN
IS
l_position          BINARY_INTEGER;
l_exist             BOOLEAN;
l_log_module        VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.IsObjectInAADCache';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of IsObjectInAADCache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_position:= 1;
l_exist   := FALSE;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => ' object_type = '||p_object   ||
                            ' - object_code = '||p_object_code      ||
                                                '-'||p_object_type_code||
                            ' - application_id ='||p_application_id||
                            ' - line_definition = '  ||p_line_definition_code     ||
                                                '-'||p_line_definition_owner_code ||
                            ' - event_class_code = '   ||p_event_class_code   ||
                            ' - event_type_code = '   ||p_event_type_code

               ,p_level  => C_LEVEL_STATEMENT
               ,p_module => l_log_module);

 END IF;

IF p_line_definition_code IS NOT NULL AND p_line_definition_owner_code IS NOT NULL THEN
--journal line type
WHILE (NOT l_exist AND  l_position <= nvl(p_rec_aad_objects.array_object_code.LAST,0) )
LOOP

  IF p_rec_aad_objects.array_object(l_position)                = p_object                       AND
     p_rec_aad_objects.array_object_code(l_position)           = p_object_code                  AND
     p_rec_aad_objects.array_object_type_code(l_position)      = p_object_type_code             AND
     p_rec_aad_objects.array_object_appl_id(l_position)        = p_application_id               AND
     p_rec_aad_objects.array_object_jld_code(l_position)       = p_line_definition_code         AND
     p_rec_aad_objects.array_object_jld_type_code(l_position)  = p_line_definition_owner_code   AND
     p_rec_aad_objects.array_object_class(l_position)          = p_event_class_code             AND
     p_rec_aad_objects.array_object_event(l_position)          = p_event_type_code
  THEN
     l_exist := TRUE;
   ELSE
     l_position := l_position + 1 ;
   END IF;

END LOOP;

ELSE
 --not journal line type
 WHILE (NOT l_exist AND  l_position <= nvl(p_rec_aad_objects.array_object_code.LAST,0) )
 LOOP

  IF p_rec_aad_objects.array_object(l_position)                = p_object                       AND
     p_rec_aad_objects.array_object_code(l_position)           = p_object_code                  AND
     p_rec_aad_objects.array_object_type_code(l_position)      = p_object_type_code             AND
     p_rec_aad_objects.array_object_appl_id(l_position)        = p_application_id

  THEN
     l_exist := TRUE;
   ELSE
     l_position := l_position + 1 ;
   END IF;

 END LOOP;

END IF;


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => ' l_exist = '||CASE l_exist
                                        WHEN TRUE THEN 'TRUE'
                                        ELSE 'FALSE'
                                       END ||
                        ' - position = '||l_position
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of IsObjectInAADCache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_position:= l_position;
RETURN l_exist;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN FALSE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.IsObjectInAADCache');
END IsObjectInAADCache;

/*--------------------------------------------------------------+
| Public function                                               |
|                                                               |
|       CacheAADObject                                          |
|                                                               |
|   Cache the AMB objects in the global cache:p_rec_aad_objects |
+--------------------------------------------------------------*/

FUNCTION CacheAADObject (
    p_object                       IN VARCHAR2
  , p_object_code                  IN VARCHAR2
  , p_object_type_code             IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_event_class_code             IN VARCHAR2
  , p_event_type_code              IN VARCHAR2
  , p_line_definition_code         IN VARCHAR2
  , p_line_definition_owner_code   IN VARCHAR2
  , p_array_source_index           IN t_array_ByInt
  , p_rec_aad_objects              IN OUT NOCOPY t_rec_aad_objects
)
RETURN BINARY_INTEGER
IS
l_position             BINARY_INTEGER;
l_exist                BOOLEAN;
l_rec_aad_objects      t_rec_aad_objects;
l_array_source         t_array_ByInt;
l_log_module           VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CacheAADObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CacheAADObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_rec_aad_objects := p_rec_aad_objects;

   l_exist:= IsObjectInAADCache (
                          p_object
                        , p_object_code
                        , p_object_type_code
                        , p_application_id
                        , p_event_class_code
                        , p_event_type_code
                        , p_line_definition_code
                        , p_line_definition_owner_code
                        , l_rec_aad_objects
                        , l_position
                        );

IF NOT l_exist THEN
 -- cache object definition in l_position
 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
         (p_msg      => 'Cached in position = '||l_position
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
 l_rec_aad_objects.array_object(l_position)               := p_object             ;
 l_rec_aad_objects.array_object_code(l_position)          := p_object_code        ;
 l_rec_aad_objects.array_object_type_code(l_position)     := p_object_type_code   ;
 l_rec_aad_objects.array_object_appl_id(l_position)       := p_application_id     ;
 l_rec_aad_objects.array_object_jld_code(l_position)      := p_line_definition_code;
 l_rec_aad_objects.array_object_jld_type_code(l_position) := p_line_definition_owner_code ;
 l_rec_aad_objects.array_object_class(l_position)         := p_event_class_code   ;
 l_rec_aad_objects.array_object_event(l_position)         := p_event_type_code    ;
 l_rec_aad_objects.array_array_object(l_position)         := p_array_source_index ;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CacheAADObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_rec_aad_objects := l_rec_aad_objects;
RETURN l_position;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_rec_aad_objects := l_rec_aad_objects;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.CacheAADObject');
END CacheAADObject;


/*--------------------------------------------------------------+
| Public function                                               |
|                                                               |
|      GetSourcesInAADObject                                    |
|                                                               |
|  Returns the sources defined in an AMB objects. It returns    |
|  the source list in p_array_source_Index and  retrieves       |
|  the source list from the AMB object cache                    |
+--------------------------------------------------------------*/

PROCEDURE GetSourcesInAADObject (
  p_object                       IN VARCHAR2
, p_object_code                  IN VARCHAR2
, p_object_type_code             IN VARCHAR2
, p_application_id               IN NUMBER
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_array_source_Index           IN OUT NOCOPY t_array_ByInt
, p_rec_aad_objects              IN t_rec_aad_objects
)
IS
l_array_source           t_array_ByInt;
l_position               BINARY_INTEGER;
l_exist                  BOOLEAN;
l_log_module             VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSourcesInAADObject';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSourcesInAADObject ='||p_array_source_Index.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

    l_exist := IsObjectInAADCache (
                           p_object
                         , p_object_code
                         , p_object_type_code
                         , p_application_id
                         , p_event_class_code
                         , p_event_type_code
                         , p_line_definition_code
                         , p_line_definition_owner_code
                         , p_rec_aad_objects
                         , l_position
                           );

IF l_exist THEN
   l_array_source := p_rec_aad_objects.array_array_object(l_position);
   IF  l_array_source.COUNT > 0 THEN
     FOR Idx IN l_array_source.FIRST .. l_array_source.LAST LOOP
       IF l_array_source.EXISTS(Idx) THEN
          p_array_source_Index(Idx) := Idx;
       END IF;
     END LOOP;
   END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetSourcesInAADObject='||p_array_source_Index.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetSourcesInAADObject');
END GetSourcesInAADObject;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| GetAADObjectPosition                                                  |
|                                                                       |
|  It returns the position/index of the AMB object in the cache         |
|                                                                       |
+======================================================================*/
FUNCTION GetAADObjectPosition (
    p_object                       IN VARCHAR2
  , p_object_code                  IN VARCHAR2
  , p_object_type_code             IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_event_class_code             IN VARCHAR2
  , p_event_type_code              IN VARCHAR2
  , p_line_definition_code         IN VARCHAR2
  , p_line_definition_owner_code   IN VARCHAR2
  , p_rec_aad_objects              IN t_rec_aad_objects
)
RETURN BINARY_INTEGER
IS
l_position           BINARY_INTEGER;
l_exist              BOOLEAN;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAADObjectPosition';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetAADObjectPosition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_exist := IsObjectInAADCache (
                           p_object
                         , p_object_code
                         , p_object_type_code
                         , p_application_id
                         , p_event_class_code
                         , p_event_type_code
                         , p_line_definition_code
                         , p_line_definition_owner_code
                         , p_rec_aad_objects
                         , l_position
                           );

IF NOT l_exist THEN l_position  := NULL; END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetAADObjectPosition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_position;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GetAADObjectPosition');
END GetAADObjectPosition;
--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|    Generate GetMeaning API for the source associated to value set        |
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
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| id_column_is_null                                                     |
|                                                                       |
| Returns true if the id column is null                                 |
|                                                                       |
+======================================================================*/
FUNCTION  id_column_is_null
  (p_flex_value_set_id               IN  NUMBER)
RETURN BOOLEAN
IS

   l_id_column_name   varchar2(240);
   l_return           boolean;
   l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.id_column_is_null';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of id_column_is_null'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_flex_value_set_id = '||p_flex_value_set_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);


END IF;

   SELECT id_column_name
     INTO l_id_column_name
     FROM fnd_flex_validation_tables
    WHERE flex_value_set_id = p_flex_value_set_id;

   IF l_id_column_name is null THEN
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of id_column_is_null'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_return;

EXCEPTION
WHEN OTHERS THEN
   RETURN FALSE;
END id_column_is_null;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|   flex_values_exist                                                   |
|                                                                       |
| Returns true if source associated to flex value set exist             |
|                                                                       |
+======================================================================*/
FUNCTION  flex_values_exist
  (p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num)
RETURN BOOLEAN
IS
l_return             boolean:= FALSE;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.flex_values_exist';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of flex_values_exist'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_array_flex_value_set_id.COUNT > 0 THEN

  FOR Idx IN p_array_flex_value_set_id.FIRST .. p_array_flex_value_set_id.LAST LOOP
  --
    IF p_array_flex_value_set_id.EXISTS(Idx) AND
       p_array_flex_value_set_id(Idx) IS NOT NULL THEN

       l_return:= TRUE;

    END IF;
  --
  END LOOP;

END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of flex_values_exist'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_return;

EXCEPTION
WHEN OTHERS THEN
   RETURN FALSE;
END flex_values_exist;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_meaning_statement                                                 |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_meaning_statement(p_flex_value_set_id        IN  NUMBER)
RETURN VARCHAR2
IS
--
l_validation_type                    VARCHAR2(1);
l_statement                          VARCHAR2(4000);
l_statement_run                      VARCHAR2(1000);
l_additional_where_clause            VARCHAR2(4000);
l_value_column_name                  VARCHAR2(4000);
l_application_table_name             VARCHAR2(4000);
l_id_column_name                     VARCHAR2(4000);
l_number                             NUMBER;
l_log_module                         VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_meaning_statement';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_meaning_statement'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

 SELECT   validation_type
   INTO   l_validation_type
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_id = p_flex_value_set_id;

   IF l_validation_type in ('I','X') THEN
      --
      -- Independant value set
      --
      l_statement_run := 'SELECT flex_value_meaning'
                         ||  xla_environment_pkg.g_chr_newline
                         || '     INTO   l_meaning_meaning'
                         ||  xla_environment_pkg.g_chr_newline
                         || '     FROM   fnd_flex_values_vl'
                         ||  xla_environment_pkg.g_chr_newline
                         ||'     WHERE  flex_value_set_id      = p_flex_value_set_id'
                         ||  xla_environment_pkg.g_chr_newline
                         || '     AND  flex_value             = p_flex_value'
                         ||  xla_environment_pkg.g_chr_newline
                         ||  '     ;'
                         ;

   ELSIF l_validation_type = 'F' THEN

      IF id_column_is_null(p_flex_value_set_id) THEN

         l_statement_run := 'l_meaning_meaning := p_flex_value;';

      ELSE

         SELECT additional_where_clause
              , value_column_name
              , application_table_name
              , id_column_name
           INTO l_additional_where_clause
              , l_value_column_name
              , l_application_table_name
              , l_id_column_name
           FROM fnd_flex_validation_tables
          WHERE flex_value_set_id = p_flex_value_set_id;

         IF l_additional_where_clause is not null THEN

            l_additional_where_clause :=
                Ltrim(l_additional_where_clause);

            l_number := Instr(Upper(l_additional_where_clause),'ORDER BY ');
            IF (l_number = 1) THEN
               l_additional_where_clause := null;
            ELSE
               l_number := Instr(Upper(l_additional_where_clause),'WHERE ');

               IF (l_number = 1) THEN
                  l_additional_where_clause :=
                    Substr(l_additional_where_clause,7);
               ELSE
                  l_additional_where_clause := l_additional_where_clause;
               END IF;
            END IF;
         END IF;

         IF l_additional_where_clause is null THEN

            --
            -- Table value set
            --
            l_statement:= 'SELECT '|| l_value_column_name
                          ||  xla_environment_pkg.g_chr_newline
                          || '     INTO   l_meaning_meaning'
                          ||  xla_environment_pkg.g_chr_newline
                          ||  '     FROM   '||l_application_table_name
                          ||  xla_environment_pkg.g_chr_newline
                          ||  '     WHERE  '||l_id_column_name  || ' = p_flex_value'
                          ||  xla_environment_pkg.g_chr_newline
                          || '     ;'
                          ;
         ELSE
            --
            -- Table value set
            --

            l_statement:= 'SELECT '||l_value_column_name
               ||  xla_environment_pkg.g_chr_newline
               || '     INTO   l_meaning_meaning'
               ||  xla_environment_pkg.g_chr_newline
               ||  '     FROM   '||l_application_table_name
               ||  xla_environment_pkg.g_chr_newline
               ||  '     WHERE  '||l_id_column_name  || ' = p_flex_value'
               ||  '      AND  '||l_additional_where_clause
               ||  '     ;'
               ;

         END IF;

        IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
             (p_msg      => '>> EXECUTE dynamic SQL = '||l_statement
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

        END IF;
        --
        --
        l_statement_run := l_statement ;
        l_statement_run := l_statement_run  || xla_environment_pkg.g_chr_newline
                          ;

      END IF;
 --
  END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_meaning_statement'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_statement_run;
EXCEPTION
WHEN OTHERS THEN
   RETURN NULL;
END get_meaning_statement;
--
--+==========================================================================+
--|                                                                          |
--| Private Function                                                         |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateGetMeaningFct(
  p_package_name                 IN VARCHAR2
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_API                VARCHAR2(32000);
l_body               VARCHAR2(30000);
l_when               VARCHAR2(10000);
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateGetMeaningFct';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateGetMeaningFct'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_API       := C_GET_MEANING_FTC;
l_body      := NULL;

FOR Idx IN p_array_flex_value_set_id.FIRST .. p_array_flex_value_set_id.LAST LOOP

   IF p_array_flex_value_set_id.EXISTS(Idx) AND
      p_array_flex_value_set_id(Idx) IS NOT NULL THEN

      l_when := C_WHEN_THEN;
      l_when := REPLACE(l_when,'$flex_value_set_id$',TO_CHAR(p_array_flex_value_set_id(Idx)));
      l_when := REPLACE(l_when,'$meaning_meaning$',get_meaning_statement(p_array_flex_value_set_id(Idx)));
      l_body := l_body || l_when;

   END IF;

END LOOP;
--
l_API     := REPLACE(l_API ,'$body$',l_body);
--
l_API     := REPLACE(l_API ,'$package_name$',p_package_name);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateGetMeaningFct'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_API;
--
EXCEPTION
   WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
        END IF;
        xla_exceptions_pkg.raise_message
                                   ('XLA'
                                   ,'XLA_CMP_COMPILER_ERROR'
                                   ,'PROCEDURE'
                                   ,'xla_cmp_source_pkg.GenerateGetMeaningFct'
                                   ,'ERROR'
                                   , sqlerrm
                                   );

   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GenerateGetMeaningFct');
END GenerateGetMeaningFct;

--+==========================================================================+
--|                                                                          |
--| Private Function                                                         |
--|                                                                          |
--+==========================================================================+
--
--
FUNCTION GenerateGetMeaning(
  p_package_name                 IN VARCHAR2
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_IsCompiled                   IN OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--
l_array_api                    DBMS_SQL.VARCHAR2S;
l_API                          VARCHAR2(32000);
--
l_IsCompiled                   BOOLEAN;
l_log_module                   VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateGetMeaning';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateGetMeaning'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Init global variables
--
l_array_api    := xla_cmp_string_pkg.g_null_varchar2s;
--
--
l_API  := GenerateGetMeaningFct(
  p_package_name                 => p_package_name
, p_array_flex_value_set_id      => p_array_flex_value_set_id
)
;
--
p_IsCompiled    := (l_API IS NOT NULL);
--
--
xla_cmp_string_pkg.CreateString(
                      p_package_text  => l_API
                     ,p_array_string  => l_array_api
                     );

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateGetMeaning'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_array_api ;
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled := FALSE;
        RETURN xla_cmp_string_pkg.g_null_varchar2s;
   WHEN OTHERS THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_source_pkg.GenerateGetMeaning');
END GenerateGetMeaning;
--
--+==========================================================================+
--|                                                                          |
--| Public Function                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateGetMeaningAPI(
  p_package_name                 IN VARCHAR2
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
IS
l_API                DBMS_SQL.VARCHAR2S;
l_IsCompiled         BOOLEAN;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateGetMeaningAPI';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateGetMeaningAPI'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Init global variables
--

l_IsCompiled   := TRUE;
l_API          := xla_cmp_string_pkg.g_null_varchar2s;
--
IF flex_values_exist(p_array_flex_value_set_id) THEN
--
l_API  := GenerateGetMeaning(
   p_package_name              =>  p_package_name
 , p_array_flex_value_set_id   =>  p_array_flex_value_set_id
 , p_IsCompiled                =>  l_IsCompiled
);
--
ELSE
--
xla_cmp_string_pkg.CreateString(
                      p_package_text  => REPLACE(C_GET_MEANING_FTC_NULL
                                                ,'$package_name$'
                                                , p_package_name)
                     ,p_array_string  => l_API
                     );

END IF;
--
p_package_body := l_API ;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   IF l_IsCompiled THEN
      trace
         (p_msg      => 'return value (l_IsCompiled) = TRUE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   ELSE
      trace
         (p_msg      => 'return value (l_IsCompiled) = FALSE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   trace
      (p_msg      => 'END of GenerateGetMeaningAPI'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RETURN FALSE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_source_pkg.GenerateGetMeaningAPI');
END GenerateGetMeaningAPI;
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
END xla_cmp_source_pkg;

/
