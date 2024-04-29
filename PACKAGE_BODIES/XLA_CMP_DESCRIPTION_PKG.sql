--------------------------------------------------------
--  DDL for Package Body XLA_CMP_DESCRIPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_DESCRIPTION_PKG" AS
/* $Header: xlacpdes.pkb 120.25.12010000.2 2010/01/31 14:50:27 vkasina ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_description_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate description procedures from AMB specifcations              |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     05-DEC-2002 K.Boussema    BUG 2693303                                  |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143  |
|     27-JUN-2003 K.Boussema    Renamed XLA_DESCRIPTION_PRIO table           |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     30-JUL-2003 K.Boussema    Updated the definition of C_FLEXFIELD_SEGMENT|
|     01-SEP-2003 K.Boussema   Changed the generation of Description function|
|     19-NOV-2003 K.boussema   Changed generate_body_desc to order the Journal Entry|
|                              description by user_sequence, bug 3266183     |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     20-Sep-2004 S.Singhania Added debug messages to GenerateDescriptions   |
|     07-Mar-2005 K.Boussema  Changed for ADR-enhancements.                  |
|     11-Jul-2005 A.Wan       Changed for MPA.                               |
+===========================================================================*/


/*------------------------------------------------------------+
|                                                             |
|                Description function template                |
|                                                             |
+------------------------------------------------------------*/

C_DESC_PROC                    CONSTANT      VARCHAR2(20000):= '
---------------------------------------
--
-- PRIVATE FUNCTION
--         Description_$desc_hash_id$
--
---------------------------------------
FUNCTION Description_$desc_hash_id$ (
  p_application_id      IN NUMBER
, p_ae_header_id        IN NUMBER DEFAULT NULL $parameters$
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
      l_log_module := C_DEFAULT_MODULE||''.Description_$desc_hash_id$'';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''BEGIN of Description_$desc_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_ledger_language       := xla_ae_journal_entry_pkg.g_cache_ledgers_info.description_language;
l_component_type        := ''AMB_DESCRIPTION'';
l_component_code        := ''$description_code$'';
l_component_type_code   := ''$desc_type_code$'';
l_component_appl_id     :=  $desc_appl_id$;
l_amb_context_code      := ''$amb_context_code$'';
l_source                := NULL;
l_description           := NULL;

$desc_body$
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => ''END of Description_$desc_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN NULL;
EXCEPTION
  WHEN VALUE_ERROR THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => ''ERROR: ''||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
     END IF;
     RAISE;
 WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => ''ERROR: ''||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      END IF;
      RAISE;
 WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => ''$package_name$.Description_$desc_hash_id$'');
END Description_$desc_hash_id$;
';


g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
--

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
g_component_type                VARCHAR2(30):='AMB_DESCRIPTION';
g_component_code                VARCHAR2(30);
g_component_type_code           VARCHAR2(1);
g_component_appl_id             INTEGER;
g_component_name                VARCHAR2(160);
g_amb_context_code              VARCHAR2(30);
--
g_package_name                  VARCHAR2(30);
g_IsCompiled                    BOOLEAN:=TRUE;
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
--               *********** Local Trace Routine **********
--=============================================================================

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_description_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2)
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
             (p_location   => 'xla_cmp_description_pkg.trace');
END trace;

/*---------------------------------------------------------------------------+
| Private function                                                           |
|                                                                            |
|       GenerateDescriptions                                                 |
|                                                                            |
| Translates a line detail description in to PL/SQL code.                    |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION generate_desc_details (
    p_description_prio_id          IN NUMBER
  , p_array_desc_source_index      IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
  , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
 )
RETURN VARCHAR2
IS

C_LITERAL_DESC        CONSTANT  VARCHAR2(20000):='
l_ledger_language = ''$language$'' THEN
    l_description :=  SUBSTR(CONCAT(l_description,''$literal$''),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,'' ''),1,2000); '
;

C_NUM_SOURCE                      CONSTANT  VARCHAR2(20000):= '
  l_source := SUBSTR(TO_CHAR($source$),1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,'' ''),1,2000);
  END IF; '
;

C_CHAR_SOURCE                     CONSTANT  VARCHAR2(20000):= '
  l_source := SUBSTR($source$,1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,'' ''),1,2000);
  END IF; '
;

C_DATE_SOURCE                 CONSTANT  VARCHAR2(20000):= '
  l_source := SUBSTR(xla_ae_sources_pkg.DATE_TO_CHAR($source$,
                     xla_ae_journal_entry_pkg.g_cache_ledgers_info.nls_desc_language),1,1996);
  IF l_source IS NOT NULL THEN
    l_description :=  SUBSTR(CONCAT(l_description,l_source),1,2000);
    l_description :=  SUBSTR(CONCAT(l_description,'' ''),1,2000);
  END IF; '
;


C_FLEXFIELD_SEGMENT         CONSTANT       VARCHAR2(20000):='
xla_ae_code_combination_pkg.get_flex_segment_value(
   p_combination_id          =>  $ccid$
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
  ,p_ae_header_id            => p_ae_header_id
) '
;

C_FLEXFIELD_DESC            CONSTANT       VARCHAR2(20000):='
xla_ae_code_combination_pkg.get_flex_segment_desc(
   p_combination_id          =>  $ccid$
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
  ,p_ae_header_id            => p_ae_header_id
) '
;

l_first                BOOLEAN;
l_Index                BINARY_INTEGER;
l_description          VARCHAR2(32000);
l_desc_detail          VARCHAR2(32000);
l_log_module           VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_desc_details';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_desc_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_description := NULL;

FOR desc_details_rec IN (SELECT    description_detail_id
                                 , value_type_code
                                 , source_code
                                 , source_type_code
                                 , source_application_id
                                 , flexfield_segment_code
                                 , display_description_flag
                                 , user_sequence
                             FROM  xla_descript_details_b
                            WHERE description_prio_id = p_description_prio_id
                            ORDER BY user_sequence ) LOOP

l_desc_detail := NULL;

IF desc_details_rec.value_type_code = 'S' THEN
 -- source
   l_Index:= xla_cmp_source_pkg.StackSource (
                p_source_code                => desc_details_rec.source_code
              , p_source_type_code           => desc_details_rec.source_type_code
              , p_source_application_id      => desc_details_rec.source_application_id
              , p_array_source_index         => p_array_desc_source_index
              , p_rec_sources                => p_rec_sources
              );

   CASE p_rec_sources.array_datatype_code(l_Index)
         WHEN 'D' THEN l_desc_detail := l_desc_detail||' '||C_DATE_SOURCE;
         WHEN 'C' THEN l_desc_detail := l_desc_detail||' '||C_CHAR_SOURCE;
         ELSE          l_desc_detail := l_desc_detail||' '||C_NUM_SOURCE;
   END CASE;


   IF desc_details_rec.flexfield_segment_code IS NULL THEN
      --not key flexfield
       l_desc_detail := REPLACE(l_desc_detail,
                       '$source$',    nvl(xla_cmp_source_pkg.GenerateSource(
                                      p_Index                     => l_Index
                                    , p_rec_sources               => p_rec_sources
                                    , p_translated_flag           => 'Y'),' null')
                                    );

   ELSIF desc_details_rec.flexfield_segment_code IS NOT NULL AND
         nvl(desc_details_rec.display_description_flag,'N')='N' THEN

         l_desc_detail := REPLACE(l_desc_detail, '$source$', C_FLEXFIELD_SEGMENT);

         l_desc_detail := REPLACE(l_desc_detail,'$ccid$',
                          xla_cmp_source_pkg.GenerateSource(
                                      p_Index                     => l_Index
                                    , p_rec_sources               => p_rec_sources
                                    , p_translated_flag           => 'N')
                                    );

         l_desc_detail := REPLACE(l_desc_detail,'$segment_code$',
                                  desc_details_rec.flexfield_segment_code);

         l_desc_detail := REPLACE(l_desc_detail,'$id_flex_code$',
                            p_rec_sources.array_id_flex_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$flexfield_appl_id$',
                            p_rec_sources.array_flexfield_appl_id(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$appl_short_name$',
                            p_rec_sources.array_appl_short_name(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_code$',
                            p_rec_sources.array_source_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_type_code$',
                            p_rec_sources.array_source_type_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_application_id$',
                            p_rec_sources.array_application_id(l_Index));

   --display flexfield description
   ELSIF desc_details_rec.flexfield_segment_code IS NOT NULL AND
         nvl(desc_details_rec.display_description_flag,'N')='Y' THEN

         l_desc_detail := REPLACE(l_desc_detail,
                       '$source$', C_FLEXFIELD_DESC);

         l_desc_detail := REPLACE(l_desc_detail,'$ccid$',
                          xla_cmp_source_pkg.GenerateSource(
                                      p_Index                     => l_Index
                                    , p_rec_sources               => p_rec_sources
                                    , p_translated_flag           => 'N')
                                    );

         l_desc_detail := REPLACE(l_desc_detail,'$segment_code$',
                                  desc_details_rec.flexfield_segment_code);

         l_desc_detail := REPLACE(l_desc_detail,'$id_flex_code$',
                            p_rec_sources.array_id_flex_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$flexfield_appl_id$',
                            p_rec_sources.array_flexfield_appl_id(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$appl_short_name$',
                            p_rec_sources.array_appl_short_name(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_code$',
                            p_rec_sources.array_source_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_type_code$',
                            p_rec_sources.array_source_type_code(l_Index));

         l_desc_detail := REPLACE(l_desc_detail,'$source_application_id$',
                            p_rec_sources.array_application_id(l_Index));

    ELSE
     null;
   END IF;

ELSIF desc_details_rec.value_type_code = 'L' THEN
 --literal
   l_first := TRUE;

   FOR literals_rec IN (SELECT  xddt.language                        language
                              , REPLACE(xddt.literal, '''','''''')   literal
                          FROM  xla_descript_details_tl  xddt
                         WHERE xddt.description_detail_id   = desc_details_rec.description_detail_id
                           AND xddt.literal IS NOT NULL ) LOOP
     IF l_first THEN
         l_desc_detail := l_desc_detail || g_chr_newline ||' IF '|| C_LITERAL_DESC ;
         l_first       := FALSE;
     ELSE
         l_desc_detail := l_desc_detail || g_chr_newline ||' ELSIF '|| C_LITERAL_DESC ;
     END IF;

     l_desc_detail  := REPLACE(l_desc_detail,'$language$',literals_rec.language);
     l_desc_detail  := REPLACE(l_desc_detail,'$literal$', literals_rec.literal);

   END LOOP;
   IF NOT l_first THEN l_desc_detail := l_desc_detail || g_chr_newline ||' END IF; '; END IF;

ELSE
   null;
END IF;

   l_description := l_description||' '||l_desc_detail;

END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_desc_details'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_description;
EXCEPTION
  WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                    trace
                       (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                       ,p_level    => C_LEVEL_EXCEPTION
                       ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
 WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                    trace
                       (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                       ,p_level    => C_LEVEL_EXCEPTION
                       ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_description_pkg.generate_desc_details ');
END generate_desc_details;

/*---------------------------------------------------------------------------+
| Private function                                                           |
|                                                                            |
|       generate_body_desc                                                   |
|                                                                            |
| Generates the body of the Description_X() function from the AMB definition |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION generate_body_desc   (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_description_code             IN VARCHAR2
, p_description_type_code        IN VARCHAR2
, p_description_name             IN VARCHAR2
, p_array_desc_source_index      IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   IN OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS

C_RETURN_DESC                     CONSTANT  VARCHAR2(10000):=
' l_description := SUBSTR(l_description,1,1996);
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
           (p_msg      => ''END of Description_$desc_hash_id$''
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);

  END IF;
  RETURN l_description;
';
l_first              BOOLEAN;
l_endif              BOOLEAN;

l_desc_body          CLOB;
l_desc_cond          VARCHAR2(32000);
l_desc_detail        VARCHAR2(32000);
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_body_desc';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_body_desc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_desc_body    := NULL;
l_desc_cond    := NULL;
l_desc_detail  := NULL;
l_first        := TRUE;
l_endif        := TRUE;

FOR desc_rec IN (SELECT description_prio_id
                      , user_sequence
                   FROM  xla_desc_priorities
                  WHERE application_id        = p_application_id
                    AND description_code      = p_description_code
                    AND description_type_code = p_description_type_code
                    AND amb_context_code      = p_amb_context_code
               ORDER BY user_sequence) LOOP

  l_desc_detail:= NULL;
  l_desc_cond  := NULL;

  l_desc_detail:= generate_desc_details(
                    p_description_prio_id        => desc_rec.description_prio_id
                  , p_array_desc_source_index    => p_array_desc_source_index
                  , p_rec_sources                => p_rec_sources
                   );

  IF l_desc_detail IS NULL THEN  l_desc_detail := 'l_description := null;'; END IF;

  l_desc_cond := xla_cmp_condition_pkg.GetCondition   (
        p_application_id             => p_application_id
      , p_component_type             => 'AMB_DESCRIPTION'
      , p_component_code             => p_description_code
      , p_component_type_code        => p_description_type_code
      , p_component_name             => p_description_name
      , p_amb_context_code           => p_amb_context_code
      , p_description_prio_id        => desc_rec.description_prio_id
      , p_array_cond_source_index    => p_array_desc_source_index
      , p_rec_sources                => p_rec_sources
       );

  IF l_desc_cond IS NULL THEN
          IF l_endif THEN
             l_desc_body   := l_desc_body ||g_chr_newline||l_desc_detail;
             l_desc_body   := l_desc_body ||g_chr_newline||C_RETURN_DESC;
             l_first  := TRUE;
          ELSE
             l_endif  := TRUE;
             l_first  := TRUE;
             l_desc_body   := l_desc_body ||g_chr_newline||'END IF;'||g_chr_newline;
             l_desc_body   := l_desc_body ||g_chr_newline||l_desc_detail;
             l_desc_body   := l_desc_body ||g_chr_newline||C_RETURN_DESC;
          END IF;
  ELSE
        IF l_first THEN
           l_desc_body     := l_desc_body ||g_chr_newline||' IF '||l_desc_cond||' THEN ';
           l_desc_body     := l_desc_body ||g_chr_newline||l_desc_detail;
           l_desc_body     := l_desc_body ||g_chr_newline||C_RETURN_DESC;
           l_first    := FALSE;
           l_endif    := FALSE;
        ELSE
            l_desc_body     := l_desc_body ||g_chr_newline||' ELSIF '||l_desc_cond||' THEN ';
            l_desc_body     := l_desc_body ||g_chr_newline||l_desc_detail;
            l_desc_body     := l_desc_body ||g_chr_newline||C_RETURN_DESC;
            l_endif         := FALSE;
        END IF;
  END IF;
END LOOP;

IF NOT l_endif AND l_desc_body IS NOT NULL THEN
      l_desc_body := l_desc_body ||g_chr_newline||' END IF;';
ELSIF l_desc_body IS NULL THEN
      l_desc_body := 'RETURN NULL;';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_body_desc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
p_IsCompiled := TRUE;
RETURN l_desc_body;
EXCEPTION
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
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
      END IF;
      p_IsCompiled := FALSE;
      RETURN NULL;
 WHEN OTHERS    THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_description_pkg.generate_body_desc ');
END generate_body_desc;

/*---------------------------------------------------------------------------+
| Private function                                                           |
|                                                                            |
|     generate_desc_fct                                                      |
|                                                                            |
| Generates a Description_X() function from the AMB description definition.  |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION generate_desc_fct (
   p_application_id               IN NUMBER
 , p_amb_context_code             IN VARCHAR2
 , p_description_code             IN VARCHAR2
 , p_description_type_code        IN VARCHAR2
 , p_description_name             IN VARCHAR2
 , p_description_level            IN VARCHAR2
 , p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
 , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
 , p_IsCompiled                   IN OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS

l_array_desc                 DBMS_SQL.VARCHAR2S;
l_null_array_desc            DBMS_SQL.VARCHAR2S;
l_description                CLOB;
l_description_code           VARCHAR2(30);
l_array_desc_source_index    xla_cmp_source_pkg.t_array_ByInt;
l_log_module                 VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.generate_desc_fct';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of generate_desc_fct'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_description_code = '||p_description_code ||
                        ' - p_description_type_code = '||p_description_type_code ||
                        ' - p_application_id = '||p_application_id ||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

g_component_code                := p_description_code ;
g_component_type_code           := p_description_type_code;
g_component_appl_id             := p_application_id ;
g_component_name                := REPLACE(p_description_name, '''','''''');
g_amb_context_code              := p_amb_context_code ;

l_description := C_DESC_PROC ;
l_description := xla_cmp_string_pkg.replace_token(l_description, '$desc_body$'   ,
                 generate_body_desc (
                  p_application_id              =>  p_application_id
                , p_amb_context_code            =>  p_amb_context_code
                , p_description_code            =>  p_description_code
                , p_description_type_code       =>  p_description_type_code
                , p_description_name            =>  p_description_name
                , p_array_desc_source_index     =>  l_array_desc_source_index
                , p_rec_sources                 =>  p_rec_sources
                , p_IsCompiled                  =>  p_IsCompiled
                               )
                );

l_description := xla_cmp_string_pkg.replace_token(l_description, '$parameters$'   ,
            xla_cmp_source_pkg.GenerateParameters(
               p_array_source_index   => l_array_desc_source_index
             , p_rec_sources          => p_rec_sources)
             );

l_description := xla_cmp_string_pkg.replace_token(l_description, '$desc_hash_id$'    ,   -- 4417664
                  TO_CHAR(xla_cmp_source_pkg.CacheAADObject (
                                p_object                    => p_description_level
                              , p_object_code               => p_description_code
                              , p_object_type_code          => p_description_type_code
                              , p_application_id            => p_application_id
                              , p_array_source_Index        => l_array_desc_source_index
                              , p_rec_aad_objects           => p_rec_aad_objects
                            )));
l_description := xla_cmp_string_pkg.replace_token(l_description, '$description_code$' , p_description_code);  -- 4417664
l_description := xla_cmp_string_pkg.replace_token(l_description, '$desc_type_code$'   , p_description_type_code);  -- 4417664
l_description := xla_cmp_string_pkg.replace_token(l_description, '$desc_appl_id$'     , TO_CHAR(p_application_id));  -- 4417664
l_description := xla_cmp_string_pkg.replace_token(l_description, '$amb_context_code$' , p_amb_context_code);  -- 4417664
l_description := xla_cmp_string_pkg.replace_token(l_description, '$package_name$'     , g_package_name);  -- 4417664

xla_cmp_string_pkg.CreateString(
                      p_package_text  => l_description
                     ,p_array_string  => l_array_desc
                     );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of generate_desc_fct = '||l_array_desc.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_array_desc;
EXCEPTION
    WHEN VALUE_ERROR THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
      END IF;
      p_IsCompiled := FALSE;
       RETURN l_null_array_desc;
   WHEN xla_exceptions_pkg.application_exception   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
      END IF;
      p_IsCompiled := FALSE;
       RETURN l_null_array_desc;
   WHEN OTHERS    THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_description_pkg.generate_desc_fct');
END generate_desc_fct;

/*---------------------------------------------------------------------------+
| Private function                                                           |
|                                                                            |
|    get_aad_descriptions                                                    |
|                                                                            |
| Launches the generation of the descriptions assigned to the AAD            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION get_aad_descriptions(
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


CURSOR description_cur
IS
--header description
(
SELECT
        xpah.description_code
      , xpah.description_type_code
      , REPLACE( xdtl.name  , '''','''''')
   FROM  xla_prod_acct_headers xpah
      , xla_descriptions_tl   xdtl
      , xla_descriptions_b    xdb
      , xla_aad_line_defn_assgns  xald
      , xla_line_definitions_b     xld

  WHERE  xpah.application_id            = p_application_id
    AND  xpah.product_rule_type_code    = p_product_rule_type_code
    AND  xpah.product_rule_code         = p_product_rule_code
    AND  xpah.amb_context_code          = p_amb_context_code
    AND  xpah.application_id            = xdb.application_id
    AND  xpah.amb_context_code          = xdb.amb_context_code
    AND  xpah.description_type_code     = xdb.description_type_code
    AND  xpah.description_code          = xdb.description_code
    AND  xpah.application_id            = xdtl.application_id (+)
    AND  xpah.amb_context_code          = xdtl.amb_context_code (+)
    AND  xpah.description_type_code     = xdtl.description_type_code (+)
    AND  xpah.description_code          = xdtl.description_code (+)
    AND  xpah.accounting_required_flag  = 'Y'
    AND  xpah.validation_status_code    = 'R'
    AND  xdtl.language             (+)  = USERENV('LANG')
    AND  xpah.description_code          IS NOT NULL
    AND  xald.application_id          = xpah.application_id
    AND  xald.amb_context_code        = xpah.amb_context_code
    AND  xald.event_class_code        = xpah.event_class_code
    AND  xald.event_type_code         = xpah.event_type_code
    AND  xald.product_rule_type_code = xpah.product_rule_type_code
    AND  xald.product_rule_code       = xpah.product_rule_code
    AND  xald.application_id          = xld.application_id
    AND  xald.amb_context_code        = xld.amb_context_code
    AND  xald.event_class_code        = xld.event_class_code
    AND  xald.event_type_code         = xld.event_type_code
    AND  xald.line_definition_owner_code = xld.line_definition_owner_code
    AND  xald.line_definition_code    = xld.line_definition_code
    AND  xld.budgetary_control_flag   = XLA_CMP_PAD_PKG.g_bc_pkg_flag
GROUP BY xpah.description_code, xpah.description_type_code, xdtl.name
)
UNION
--line description
(
SELECT
        xldj.description_code
      , xldj.description_type_code
      , REPLACE(xdtl.name , '''','''''')
  FROM  xla_aad_line_defn_assgns   xald
      , xla_line_defn_jlt_assgns   xldj
      , xla_prod_acct_headers      xpah
      , xla_descriptions_tl        xdtl
      , xla_descriptions_b         xdb
      , xla_line_definitions_b     xld
 WHERE  xpah.application_id             = p_application_id
   AND  xpah.amb_context_code           = p_amb_context_code
   AND  xpah.product_rule_type_code     = p_product_rule_type_code
   AND  xpah.product_rule_code          = p_product_rule_code
   AND  xpah.accounting_required_flag   = 'Y'
   AND  xpah.validation_status_code     = 'R'
   --
   AND  xald.application_id             = xpah.application_id
   AND  xald.amb_context_code           = xpah.amb_context_code
   AND  xald.event_class_code           = xpah.event_class_code
   AND  xald.event_type_code            = xpah.event_type_code
   AND  xald.product_rule_type_code     = xpah.product_rule_type_code
   AND  xald.product_rule_code          = xpah.product_rule_code
   --
   AND  xldj.application_id             = xald.application_id
   AND  xldj.amb_context_code           = xald.amb_context_code
   AND  xldj.event_class_code           = xald.event_class_code
   AND  xldj.event_type_code            = xald.event_type_code
   AND  xldj.line_definition_owner_code = xald.line_definition_owner_code
   AND  xldj.line_definition_code       = xald.line_definition_code
   AND  xldj.active_flag                = 'Y'
   AND  xldj.description_code           IS NOT NULL
   --
   AND  xldj.application_id             = xdtl.application_id  (+)
   AND  xldj.amb_context_code           = xdtl.amb_context_code (+)
   AND  xldj.description_type_code      = xdtl.description_type_code (+)
   AND  xldj.description_code           = xdtl.description_code (+)
   AND  xdtl.language              (+)  = USERENV('LANG')
   --
   AND  xldj.application_id             = xdb.application_id
   AND  xldj.amb_context_code           = xdb.amb_context_code
   AND  xldj.description_type_code      = xdb.description_type_code
   AND  xldj.description_code           = xdb.description_code
   AND  xdb.enabled_flag                = 'Y'
   --
   AND  xald.application_id         = xld.application_id
   AND  xald.amb_context_code       = xld.amb_context_code
   AND  xald.event_class_code       = xld.event_class_code
   AND  xald.event_type_code        = xld.event_type_code
   AND  xald.line_definition_owner_code = xld.line_definition_owner_code
   AND  xald.line_definition_code  = xld.line_definition_code
   AND  xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
GROUP BY xldj.description_code, xldj.description_type_code, xdtl.name
)
UNION   -- 4262811
-- mpa header description
(
SELECT
        xldj.mpa_header_desc_code
      , xldj.mpa_header_desc_type_code
      , REPLACE(xdtl.name , '''','''''')
  FROM  xla_prod_acct_headers      xpah
      , xla_aad_line_defn_assgns   xald
      , xla_line_defn_jlt_assgns   xldj
      , xla_descriptions_tl        xdtl
      , xla_descriptions_b         xdb
      , xla_line_definitions_b     xld
 WHERE  xpah.application_id             = p_application_id
   AND  xpah.amb_context_code           = p_amb_context_code
   AND  xpah.product_rule_type_code     = p_product_rule_type_code
   AND  xpah.product_rule_code          = p_product_rule_code
   AND  xpah.accounting_required_flag   = 'Y'
   AND  xpah.validation_status_code     = 'R'
   --
   AND  xald.application_id             = xpah.application_id
   AND  xald.amb_context_code           = xpah.amb_context_code
   AND  xald.event_class_code           = xpah.event_class_code
   AND  xald.event_type_code            = xpah.event_type_code
   AND  xald.product_rule_type_code     = xpah.product_rule_type_code
   AND  xald.product_rule_code          = xpah.product_rule_code
   --
   AND  xldj.application_id             = xald.application_id
   AND  xldj.amb_context_code           = xald.amb_context_code
   AND  xldj.event_class_code           = xald.event_class_code
   AND  xldj.event_type_code            = xald.event_type_code
   AND  xldj.line_definition_owner_code = xald.line_definition_owner_code
   AND  xldj.line_definition_code       = xald.line_definition_code
   AND  xldj.active_flag                = 'Y'
   AND  xldj.mpa_header_desc_code       IS NOT NULL
   --
   AND  xldj.application_id             = xdtl.application_id  (+)
   AND  xldj.amb_context_code           = xdtl.amb_context_code (+)
   AND  xldj.mpa_header_desc_type_code  = xdtl.description_type_code (+)
   AND  xldj.mpa_header_desc_code       = xdtl.description_code (+)
   AND  xdtl.language              (+)  = USERENV('LANG')
   --
   AND  xldj.application_id             = xdb.application_id
   AND  xldj.amb_context_code           = xdb.amb_context_code
   AND  xldj.mpa_header_desc_type_code  = xdb.description_type_code
   AND  xldj.mpa_header_desc_code       = xdb.description_code
   AND  xdb.enabled_flag                = 'Y'
   --
   AND xald.application_id         = xld.application_id
   AND xald.amb_context_code       = xld.amb_context_code
   AND xald.event_class_code       = xld.event_class_code
   AND xald.event_type_code        = xld.event_type_code
   AND xald.line_definition_owner_code = xld.line_definition_owner_code
   AND xald.line_definition_code  = xld.line_definition_code
   AND xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
)
UNION   -- 4262811
-- mpa line description
(
SELECT
        xmja.description_code
      , xmja.description_type_code
      , REPLACE(xdtl.name , '''','''''')
  FROM  xla_prod_acct_headers      xpah
      , xla_aad_line_defn_assgns   xald
      , xla_mpa_jlt_assgns         xmja
      , xla_line_defn_jlt_assgns   xldj
      , xla_descriptions_tl        xdtl
      , xla_descriptions_b         xdb
      , xla_line_definitions_b     xld
 WHERE  xpah.application_id             = p_application_id
   AND  xpah.amb_context_code           = p_amb_context_code
   AND  xpah.product_rule_type_code     = p_product_rule_type_code
   AND  xpah.product_rule_code          = p_product_rule_code
   AND  xpah.accounting_required_flag   = 'Y'
   AND  xpah.validation_status_code     = 'R'
   --
   AND  xald.application_id             = xpah.application_id
   AND  xald.amb_context_code           = xpah.amb_context_code
   AND  xald.event_class_code           = xpah.event_class_code
   AND  xald.event_type_code            = xpah.event_type_code
   AND  xald.product_rule_type_code     = xpah.product_rule_type_code
   AND  xald.product_rule_code          = xpah.product_rule_code
   --
   AND  xmja.application_id             = xald.application_id
   AND  xmja.amb_context_code           = xald.amb_context_code
   AND  xmja.event_class_code           = xald.event_class_code
   AND  xmja.event_type_code            = xald.event_type_code
   AND  xmja.line_definition_owner_code = xald.line_definition_owner_code
   AND  xmja.line_definition_code       = xald.line_definition_code
   AND  xmja.description_code          IS NOT NULL
   --
   AND  xldj.application_id             = xmja.application_id
   AND  xldj.amb_context_code           = xmja.amb_context_code
   AND  xldj.event_class_code           = xmja.event_class_code
   AND  xldj.event_type_code            = xmja.event_type_code
   AND  xldj.line_definition_owner_code = xmja.line_definition_owner_code
   AND  xldj.line_definition_code       = xmja.line_definition_code
   AND  xldj.active_flag                = 'Y'
   --
   AND  xmja.application_id             = xdtl.application_id  (+)
   AND  xmja.amb_context_code           = xdtl.amb_context_code (+)
   AND  xmja.description_type_code      = xdtl.description_type_code (+)
   AND  xmja.description_code           = xdtl.description_code (+)
   AND  xdtl.language              (+)  = USERENV('LANG')
   --
   AND  xmja.application_id             = xdb.application_id
   AND  xmja.amb_context_code           = xdb.amb_context_code
   AND  xmja.description_type_code      = xdb.description_type_code
   AND  xmja.description_code           = xdb.description_code
   AND  xdb.enabled_flag                = 'Y'
   --
   AND  xald.application_id         = xld.application_id
   AND  xald.amb_context_code       = xld.amb_context_code
   AND  xald.event_class_code       = xld.event_class_code
   AND  xald.event_type_code        = xld.event_type_code
   AND  xald.line_definition_owner_code = xld.line_definition_owner_code
   AND  xald.line_definition_code  = xld.line_definition_code
   AND  xld.budgetary_control_flag = XLA_CMP_PAD_PKG.g_bc_pkg_flag
)
;

l_array_desc_code               xla_cmp_source_pkg.t_array_VL30;
l_array_desc_name               xla_cmp_source_pkg.t_array_VL80;
l_array_desc_owner              xla_cmp_source_pkg.t_array_VL1;

l_descriptions                  DBMS_SQL.VARCHAR2S;
l_null_descriptions             DBMS_SQL.VARCHAR2S;

l_IsCompiled             BOOLEAN;
l_log_module             VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_aad_descriptions';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of get_aad_descriptions'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code||
                        ' - p_application_id = '||p_application_id||
                        ' - p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
l_descriptions   := l_null_descriptions;
p_IsCompiled     := TRUE;
l_IsCompiled     := TRUE;


OPEN  description_cur ;

FETCH description_cur  BULK COLLECT INTO   l_array_desc_code
                                         , l_array_desc_owner
                                         , l_array_desc_name
                                        ;
CLOSE description_cur ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => '# number of descriptions = '||l_array_desc_code.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF l_array_desc_code.COUNT > 0 THEN
FOR Idx IN l_array_desc_code.FIRST .. l_array_desc_code.LAST  LOOP

  IF l_array_desc_code.EXISTS(Idx) THEN

     l_descriptions := xla_cmp_string_pkg.ConcatTwoStrings (
                            p_array_string_1    => l_descriptions
                           ,p_array_string_2    => generate_desc_fct (
                                       p_application_id         => p_application_id
                                     , p_amb_context_code       => p_amb_context_code
                                     , p_description_code       => l_array_desc_code(Idx)
                                     , p_description_type_code  => l_array_desc_owner(Idx)
                                     , p_description_name       => l_array_desc_name(Idx)
                                     , p_description_level      => xla_cmp_source_pkg.C_DESC
                                     , p_rec_aad_objects        => p_rec_aad_objects
                                     , p_rec_sources            => p_rec_sources
                                     , p_IsCompiled             => l_IsCompiled )
                      );

      p_IsCompiled := p_IsCompiled  AND l_IsCompiled ;

  END IF;
END LOOP;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of get_aad_descriptions'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_descriptions;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
        END IF;
        p_IsCompiled := FALSE;
        RETURN l_null_descriptions;
   WHEN OTHERS    THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
      END IF;
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_description_pkg.get_aad_descriptions');
END get_aad_descriptions;

/*---------------------------------------------------------------------------+
| Public function                                                            |
|                                                                            |
|       GenerateDescriptions                                                 |
|                                                                            |
| Translates the AMB descriptions assigned to an AAD into PL/SQL functions   |
| Description_XXX(). It returns True if the generation succeeds, False       |
| otherwise.                                                                 |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateDescriptions(
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
l_descriptions            DBMS_SQL.VARCHAR2S;
l_null_descriptions       DBMS_SQL.VARCHAR2S;
l_IsCompiled              BOOLEAN;
p_IsCompiled              BOOLEAN;
l_log_module              VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateDescriptions';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateDescriptions'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_IsCompiled   := TRUE;
p_IsCompiled   := TRUE;
g_package_name := p_package_name;

l_descriptions :=  get_aad_descriptions(
   p_product_rule_code         =>  p_product_rule_code
 , p_product_rule_type_code    =>  p_product_rule_type_code
 , p_application_id            =>  p_application_id
 , p_amb_context_code          =>  p_amb_context_code
 , p_rec_aad_objects           =>  p_rec_aad_objects
 , p_rec_sources               =>  p_rec_sources
 , p_IsCompiled                =>  l_IsCompiled
 );

p_IsCompiled := p_IsCompiled  AND l_IsCompiled ;

p_package_body := l_descriptions;
g_package_name := NULL;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'return value = '||
                           CASE p_IsCompiled
                             WHEN TRUE THEN 'TRUE'
                             ELSE 'FALSE'
                           END
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of GenerateDescriptions = '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN p_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
                (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                ,p_level    => C_LEVEL_EXCEPTION
                ,p_module   => l_log_module);
   END IF;
   RETURN FALSE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_description_pkg.GenerateDesciptions');
END GenerateDescriptions;
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

END xla_cmp_description_pkg;
--

/
