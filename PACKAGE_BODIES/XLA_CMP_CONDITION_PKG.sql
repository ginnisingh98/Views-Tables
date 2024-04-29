--------------------------------------------------------
--  DDL for Package Body XLA_CMP_CONDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_CONDITION_PKG" AS
/* $Header: xlacpcod.pkb 120.28.12010000.2 2010/01/31 14:49:52 vkasina ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_condition_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate conditions expressions from AMB specifcations              |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     15-JUN-2002 K.Boussema  Created                                        |
|     18-FEB-2003 K.Boussema  Added 'dbdrv' command                          |
|     21-FEB-2003 K.Boussela  Changed GetCondition function                  |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143  |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     30-JUL-2003 K.Boussema    Updated the definition of C_FLEXFIELD_SEGMENT|
|     27-SEP-2003 K.Boussema    Reviewed the generation of conditions        |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     28-APR-2004 K.Boussema  Bug 3596711:                                   |
|                                Changed the compiler to allow a row in cond.|
|                                with just one bracket, reviewed             |
|                                GetOneCondition() function                  |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     01-JUN-2004 A.Quaglia   Added changes for Transaction Account Builder  |
|                             added C_TAD_FLEXFIELD_SEGMENT                  |
|                             modified GetOneRowCondition                    |
|     02-JUN-2004 A.Quaglia   Changed TAD_ADR with TAB_ADR                   |
|     07-Mar-2005 K.Boussema  Changed for ADR-enhancements.                  |
|     11-Oct-2005 Jorge Larre Fix for bug 4567102: the compiler must         |
|                 consider that when using a segment of a source of type     |
|                 flexfield in a condition, if the right operand is a        |
|                 constant, the right operand must be treated as a char and  |
|                 not as a number.                                           |
+===========================================================================*/
--

g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
g_chr_dummy        CONSTANT VARCHAR2(10):= '@#$';
--
-- Get flexfield segment
--
--

C_FLEXFIELD_SEGMENT                     CONSTANT       VARCHAR2(10000):='
--
xla_ae_code_combination_pkg.get_flex_segment_value(
   p_combination_id          =>  $ccid$
 , p_segment_code            => ''$segment_code$''
 , p_id_flex_code            => ''$id_flex_code$''
 , p_flex_application_id     => $flexfield_appl_id$
 , p_application_short_name  => ''$appl_short_name$''
 , p_source_code             => ''$source_code$''
 , p_source_type_code        => ''$source_type_code$''
 , p_source_application_id   => $source_application_id$
 , p_component_type          => ''$component_type$''
 , p_component_code          => ''$component_code$''
 , p_component_type_code     => ''$component_type_code$''
 , p_component_appl_id       => $component_appl_id$
 , p_amb_context_code        => ''$amb_context_code$''
 , p_entity_code             => NULL
 , p_event_class_code        => NULL
 , p_ae_header_id            => NULL
)'
;

C_FLEXFIELD_SEGMENT_2                    CONSTANT       VARCHAR2(10000):='
--
xla_ae_code_combination_pkg.get_flex_segment_value(
   p_combination_id          =>  $ccid$
  ,p_segment_code            => ''$segment_code$''
  ,p_id_flex_code            => ''$id_flex_code$''
  ,p_flex_application_id     => $flexfield_appl_id$
  ,p_application_short_name => ''$appl_short_name$''
  ,p_source_code             => ''$source_code$''
  ,p_source_type_code        => ''$source_type_code$''
  ,p_source_application_id   => $source_application_id$
  ,p_component_type          => ''$component_type$''
  ,p_component_code          => ''$component_code$''
  ,p_component_type_code     => ''$component_type_code$''
  ,p_component_appl_id       => $component_appl_id$
  ,p_amb_context_code        => ''$amb_context_code$''
  ,p_entity_code             => ''$entity_code$''
  ,p_event_class_code        => ''$event_class_code$''
  ,p_ae_header_id            => NULL
)'
;


C_TAD_FLEXFIELD_SEGMENT                     CONSTANT       VARCHAR2(10000):='
--
get_flexfield_segment(
   p_mode                            => p_mode
  ,p_rowid                           => p_rowid
  ,p_line_index                      => p_line_index
  ,p_chart_of_accounts_id            => p_chart_of_accounts_id
  ,p_chart_of_accounts_name          => p_chart_of_accounts_name
  ,p_ccid                            =>  $ccid$
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
--+==========================================================================+
--|                                                                          |
--|   Global Variable                                                        |
--|                                                                          |
--+==========================================================================+
--
g_component_type                VARCHAR2(30);
g_component_code                VARCHAR2(30);
g_component_type_code           VARCHAR2(1);
g_component_appl_id             INTEGER;
g_component_name                VARCHAR2(160);
g_amb_context_code              VARCHAR2(30);
g_entity_code                   VARCHAR2(30);
g_event_class_code              VARCHAR2(30);
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
--                  FND trace
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_condition_pkg';

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
             (p_location   => 'xla_cmp_condition_pkg.trace');
END trace;
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
--                 CONDITION translator
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
--+==========================================================================+
--|                                                                          |
--| PRIVATE Function                                                         |
--|                                                                          |
--|                                                                          |
--|       Name        : GetOneRowCondition                                   |
--|                                                                          |
--|       Description : Generates a PL/SQL code from one row condition       |
--|                     specified in an AMB condition. Does not perform      |
--|                     any syntactic validations on the row condition.      |
--|                     Validations are handled by the AMB and the PL/SQL    |
--|                     compiler.                                            |
--|                                                                          |
--|       Return      : Returns a varchar containing a PL/SQL code generated |
--|                     from the row condition specification                 |
--|                                                                          |
--+==========================================================================+

FUNCTION GetOneRowCondition   (
   p_condition_id               IN NUMBER
 , p_array_cond_source_index    IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
 , p_rec_sources                IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
 )
RETURN VARCHAR2
IS
--
--
CURSOR cond_cur (p_condition NUMBER) IS
SELECT    xc.user_sequence                    user_sequence
       ,  xc.bracket_left_code                bracket_left_code
       ,  xc.bracket_right_code               bracket_right_code
       ,  xc.source_application_id            source_application_id
       ,  xc.source_type_code                 source_type_code
       ,  xc.source_code                      source_code
       ,  xc.flexfield_segment_code           flexfield_segment
       ,  xc.value_type_code                  value_type_code
       ,  xc.value_source_application_id      value_source_application_id
       ,  xc.value_source_type_code           value_source_type_code
       ,  xc.value_source_code                value_source_code
       ,  xc.value_flexfield_segment_code     value_flexfield_segment
       ,  xc.value_constant                   value_constant
       ,  xc.line_operator_code               line_operator_code
       ,  xc.logical_operator_code            logical_operator_code
FROM   xla_conditions  xc
WHERE  condition_id        =  p_condition
;
cond_r               cond_cur%ROWTYPE;
l_Idx                BINARY_INTEGER;
l_cond               VARCHAR2(32000);
l_source             VARCHAR2(32000);
l_seg                VARCHAR2(32000);
l_rec_sources        xla_cmp_source_pkg.t_rec_sources;
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetOneRowCondition';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetOneRowCondition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_cond := NULL;
l_seg  := NULL;
l_rec_sources  := p_rec_sources;

OPEN cond_cur(p_condition_id);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - FETCH from xla_conditions  '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

FETCH cond_cur INTO cond_r;
CLOSE cond_cur;

-- ============
-- left bracket
-- ============
l_cond := l_cond || NVL(cond_r.bracket_left_code,'') ;

-- ============
-- left operand
-- ============
IF cond_r.source_code IS NOT NULL THEN

       l_Idx := xla_cmp_source_pkg.StackSource  (
                          p_source_code              => cond_r.source_code
                        , p_source_type_code         => cond_r.source_type_code
                        , p_source_application_id    => cond_r.source_application_id
                        , p_array_source_index       => p_array_cond_source_index
                        , p_rec_sources              => l_rec_sources
              );

       IF (cond_r.flexfield_segment IS NULL) THEN
         l_source := xla_cmp_source_pkg.GenerateSource(
                               p_Index                     => l_Idx
                             , p_rec_sources               => l_rec_sources
                             , p_translated_flag           => 'N'
                             );

         IF NVL(cond_r.line_operator_code,'   ') IN ('D','E') THEN
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                 trace
                    (p_msg      => 'add nvl'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   => l_log_module);
           END IF;
           IF l_rec_sources.array_datatype_code(l_Idx) = 'D' THEN
             l_cond := l_cond || 'NVL('||l_source||',TO_DATE(''1'',''j'')) ' ;
           ELSIF l_rec_sources.array_datatype_code(l_Idx) = 'C' THEN
             l_cond := l_cond || 'NVL('||l_source||',''
'') ' ;
           ELSE
             l_cond := l_cond || 'NVL('||l_source||',9E125) ' ;
           END IF;

         ELSE
           l_cond := l_cond || l_source || ' ' ;
         END IF;

       ELSE
         --
         IF g_component_type = 'TAB_ADR'
         THEN
            l_seg  := C_TAD_FLEXFIELD_SEGMENT;
         ELSE
            IF g_entity_code IS NULL AND g_event_class_code IS NULL THEN
               l_seg  := C_FLEXFIELD_SEGMENT;
            ELSE
               l_seg  := C_FLEXFIELD_SEGMENT_2;
            END IF;
         END IF;

         --
         l_seg  := REPLACE(l_seg,'$ccid$', nvl(xla_cmp_source_pkg.GenerateSource(
                               p_Index                     => l_Idx
                             , p_rec_sources               => l_rec_sources
                             , p_translated_flag           => 'N'),' null')
                             );

         l_seg := REPLACE(l_seg,'$segment_code$'         , nvl(cond_r.flexfield_segment,' '));
         l_seg := REPLACE(l_seg,'$id_flex_code$'         , nvl(l_rec_sources.array_id_flex_code(l_Idx),' '));
         l_seg := REPLACE(l_seg,'$flexfield_appl_id$'    , nvl(TO_CHAR(l_rec_sources.array_flexfield_appl_id(l_Idx)),' '));
         l_seg := REPLACE(l_seg,'$appl_short_name$'      , nvl(l_rec_sources.array_appl_short_name(l_Idx),' ')  );
         l_seg := REPLACE(l_seg,'$source_code$'          , nvl(l_rec_sources.array_source_code(l_Idx),' ')      );
         l_seg := REPLACE(l_seg,'$source_type_code$'     , nvl(l_rec_sources.array_source_type_code(l_Idx),' ') );
         l_seg := REPLACE(l_seg,'$source_application_id$', nvl(TO_CHAR(l_rec_sources.array_application_id(l_Idx)),' ')  );
         l_seg := REPLACE(l_seg,'$component_type$'       , nvl(g_component_type,' '));
         l_seg := REPLACE(l_seg,'$component_code$'       , nvl(g_component_code,' ') );
         l_seg := REPLACE(l_seg,'$component_type_code$'  , nvl(g_component_type_code,' ') );
         l_seg := REPLACE(l_seg,'$component_appl_id$'    , nvl(TO_CHAR(g_component_appl_id),' ') );
         l_seg := REPLACE(l_seg,'$amb_context_code$'     , nvl(g_amb_context_code ,' '));
         l_seg := REPLACE(l_seg,'$entity_code$'          , nvl(g_entity_code ,' '));
         l_seg := REPLACE(l_seg,'$event_class_code$'     , nvl(g_event_class_code,' ') );

         IF NVL(cond_r.line_operator_code,'   ') IN ('D','E') THEN
            --
            -- D: '!='
            -- E: '='
            --
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 (p_msg      => 'add nvl to segment'
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
            END IF;

            l_cond := l_cond || 'NVL(' || l_seg || ',''' || g_chr_dummy ||''')';

         ELSE

            l_cond := l_cond || l_seg;

         END IF;--

       END IF;
 ELSE
   null;
 END IF;

 -- ==========
 --  operator
 -- ==========
 IF cond_r.line_operator_code IS NOT NULL  THEN

     -- bugfix 6024311: since Meaning in lookup table will be translated,
     --                 do not use get_meaning() for meanings that are 'operators'.

   IF(cond_r.logical_operator_code = 'N') THEN
     l_cond := rtrim(l_cond) ||' IS NULL ';
   ELSIF(cond_r.logical_operator_code = 'X') THEN
     l_cond := rtrim(l_cond) ||' IS NOT NULL ';
   ELSE
     l_cond := rtrim(l_cond) ||' '
               || REPLACE(xla_lookups_pkg.get_meaning('XLA_LINE_OPERATOR_TYPE', cond_r.line_operator_code)
                          ,'!=','<>')||' ';
   END IF;

 END IF;

 -- ===============
 --  right operand
 -- ===============
 IF cond_r.value_type_code= 'S'  THEN
 --
 -- source operand
 --
     IF cond_r.value_source_code IS NOT NULL THEN

              l_Idx := xla_cmp_source_pkg.StackSource  (
                             p_source_code                => cond_r.value_source_code
                           , p_source_type_code           => cond_r.value_source_type_code
                           , p_source_application_id      => cond_r.value_source_application_id
                           , p_array_source_index         => p_array_cond_source_index
                           , p_rec_sources              => l_rec_sources
              );

           IF (cond_r.value_flexfield_segment IS NULL) THEN
                l_source := xla_cmp_source_pkg.GenerateSource(
                               p_Index                     => l_Idx
                             , p_rec_sources               => l_rec_sources
                             , p_translated_flag           => 'N');
                --
                IF NVL(cond_r.line_operator_code,'   ') IN ('D','E') THEN
                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                        trace
                           (p_msg      => 'add nvl'
                           ,p_level    => C_LEVEL_STATEMENT
                           ,p_module   => l_log_module);
                  END IF;
                  IF l_rec_sources.array_datatype_code(l_Idx) = 'D' THEN
                    l_cond := l_cond || 'NVL('||l_source||',TO_DATE(''1'',''j'')) ' ;
                  ELSIF l_rec_sources.array_datatype_code(l_Idx) = 'C' THEN
                    l_cond := l_cond || 'NVL('||l_source||',''
'') ' ;
                  ELSE
                    l_cond := l_cond || 'NVL('||l_source||',9E125) ' ;
                  END IF;

                ELSE
                  l_cond := l_cond || l_source || ' ' ;
                END IF;

           ELSE
                --
                IF g_component_type = 'TAB_ADR'
                THEN
                   l_seg  := C_TAD_FLEXFIELD_SEGMENT;
                ELSE
                   IF g_entity_code IS NULL AND g_event_class_code IS NULL THEN
                      l_seg  := C_FLEXFIELD_SEGMENT;
                   ELSE
                      l_seg  := C_FLEXFIELD_SEGMENT_2;
                   END IF;
                END IF;

                l_seg  := REPLACE(l_seg,'$ccid$', nvl(xla_cmp_source_pkg.GenerateSource(
                               p_Index                     => l_Idx
                             , p_rec_sources               => l_rec_sources
                             , p_translated_flag           => 'N'),' null')
                             );

                l_seg := REPLACE(l_seg,'$segment_code$'         , nvl(cond_r.value_flexfield_segment,' '));
                l_seg := REPLACE(l_seg,'$id_flex_code$'         , nvl(l_rec_sources.array_id_flex_code(l_Idx),' ')     );
                l_seg := REPLACE(l_seg,'$flexfield_appl_id$'    , nvl(TO_CHAR(l_rec_sources.array_flexfield_appl_id(l_Idx)),' '));
                l_seg := REPLACE(l_seg,'$appl_short_name$'      , nvl(l_rec_sources.array_appl_short_name(l_Idx),' ')  );
                l_seg := REPLACE(l_seg,'$source_code$'          , nvl(l_rec_sources.array_source_code(l_Idx) ,' '));
                l_seg := REPLACE(l_seg,'$source_type_code$'     , nvl(l_rec_sources.array_source_type_code(l_Idx),' ') );
                l_seg := REPLACE(l_seg,'$source_application_id$', nvl(TO_CHAR(l_rec_sources.array_application_id(l_Idx)) ,' '));
                l_seg := REPLACE(l_seg,'$component_type$'       , nvl(g_component_type,' '));
                l_seg := REPLACE(l_seg,'$component_code$'       , nvl(g_component_code ,' '));
                l_seg := REPLACE(l_seg,'$component_type_code$'  , nvl(g_component_type_code ,' '));
                l_seg := REPLACE(l_seg,'$component_appl_id$'    , nvl(TO_CHAR(g_component_appl_id) ,' '));
                l_seg := REPLACE(l_seg,'$amb_context_code$'     , nvl(g_amb_context_code ,' '));
                l_seg := REPLACE(l_seg,'$entity_code$'          , nvl(g_entity_code ,' '));
                l_seg := REPLACE(l_seg,'$event_class_code$'     , nvl(g_event_class_code ,' '));
                --
             IF NVL(cond_r.line_operator_code,'   ') IN ('D','E') THEN
                --
                -- D: '!='
                -- E: '='
                --
                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    (p_msg      => 'add nvl to segment'
                    ,p_level    => C_LEVEL_STATEMENT
                    ,p_module   => l_log_module);
                END IF;

                l_cond := l_cond || 'NVL(' || l_seg || ',''' || g_chr_dummy ||''')';

             ELSE

                l_cond := l_cond || l_seg;

             END IF;--                --
          END IF;
             --
       END IF;
       --
   ELSIF  cond_r.value_type_code = 'C' THEN

       IF cond_r.flexfield_segment is NULL THEN

          IF  l_rec_sources.array_datatype_code(l_Idx) = 'D' THEN
          -- date
              l_cond := l_cond ||REPLACE(' fnd_date.canonical_to_date(''$date$'')'
                                         ,'$date$', cond_r.value_constant);
          --
          ELSIF  l_rec_sources.array_datatype_code(l_Idx)   = 'C' THEN
          --char
           l_cond := l_cond ||' '||''''||REPLACE(cond_r.value_constant,'''','''''')||'''';

          ELSIF (l_rec_sources.array_datatype_code(l_Idx)  = 'N' OR
                 l_rec_sources.array_datatype_code(l_Idx)  = 'I' OR
                 l_rec_sources.array_datatype_code(l_Idx)  = 'F' ) THEN
          --number
                 l_cond := l_cond ||' '|| cond_r.value_constant;
          END IF;
       ELSE
          --consider the right operand as a char
          l_cond := l_cond ||' '||''''||REPLACE(cond_r.value_constant,'''','''''')||'''';
       END IF;
ELSE
  null;
END IF;
-- ===============
--  right bracket
-- ===============
l_cond := l_cond ||NVL(cond_r.bracket_right_code,'');

-- ================
--  logic operator
-- ================
IF cond_r.logical_operator_code IS NOT NULL THEN

   -- bugfix 6024311: since Meaning in lookup table will be translated,
   --                 do not use get_meaning() for lookup_type XLA_LOGICAL_OPERATOR_TYPE
   /*
   l_cond := l_cond ||' '||xla_lookups_pkg.get_meaning('XLA_LOGICAL_OPERATOR_TYPE',
                                                   cond_r.logical_operator_code )||' ';
   */
   IF(cond_r.logical_operator_code = 'A') THEN
    	l_cond := rtrim(l_cond) ||' AND ';
   ELSIF(cond_r.logical_operator_code = 'O') THEN
    	l_cond := rtrim(l_cond) ||' OR ';
   END IF;

END IF;
--
-- add new line if operands are not null
--
IF cond_r.source_code IS NOT NULL THEN
          l_cond := l_cond || g_chr_newline;
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'END of GetOneRowCondition'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;
p_rec_sources  := l_rec_sources;
RETURN l_cond;
EXCEPTION
WHEN VALUE_ERROR THEN
     IF cond_cur%ISOPEN THEN CLOSE cond_cur; END IF;
     p_rec_sources  := l_rec_sources;
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
     END IF;
     RETURN NULL;
WHEN xla_exceptions_pkg.application_exception   THEN
        IF cond_cur%ISOPEN THEN CLOSE cond_cur; END IF;
        p_rec_sources  := l_rec_sources;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
WHEN OTHERS    THEN
      IF cond_cur%ISOPEN THEN CLOSE cond_cur; END IF;
      p_rec_sources  := l_rec_sources;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_condition_pkg.GetOneRowCondition ');
END GetOneRowCondition;


--+==========================================================================+
--|                                                                          |
--| PUBLIC Function                                                          |
--|                                                                          |
--|                                                                          |
--|       Name        : GetCondition                                         |
--|                                                                          |
--|       Description : Generates a PL/SQL code from AMB condition           |
--|                     specified in an AMB condition. Does not perform      |
--|                     any syntactic validations on AMB condition.          |
--|                     Validations are handled by the AMB and the PL/SQL    |
--|                     compiler.                                            |
--|                                                                          |
--|       Return      : Returns the translation of the AMB condition into    |
--|                     PL/SQL code                                          |
--|                                                                          |
--+==========================================================================+

FUNCTION GetCondition   (
   p_application_id               IN NUMBER
 , p_component_type               IN VARCHAR2
 , p_component_code               IN VARCHAR2
 , p_component_type_code          IN VARCHAR2
 , p_component_name               IN VARCHAR2
 , p_entity_code                  IN VARCHAR2
 , p_event_class_code             IN VARCHAR2
 , p_amb_context_code             IN VARCHAR2
 --
 , p_description_prio_id          IN NUMBER
 , p_acctg_line_code              IN VARCHAR2
 , p_acctg_line_type_code         IN VARCHAR2
 , p_segment_rule_detail_id       IN NUMBER
 --
 , p_array_cond_source_index      IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
 --
 , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN VARCHAR2
IS
--
l_cond               VARCHAR2(32000);
l_log_module         VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetCondition';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetCondition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
g_component_type              := p_component_type;
g_component_code              := p_component_code;
g_component_type_code         := p_component_type_code;
g_component_name              := p_component_name;
g_component_appl_id           := p_application_id;
g_entity_code                 := p_entity_code;
g_event_class_code            := p_event_class_code;
g_amb_context_code            := p_amb_context_code;
l_cond                        := NULL;
--

IF  p_description_prio_id IS NOT NULL THEN
    FOR condition_rec IN (
        SELECT   condition_id
               , user_sequence
         FROM    xla_conditions xc
        WHERE xc.application_id   = p_application_id
          AND xc.amb_context_code = p_amb_context_code
          AND xc.description_prio_id = p_description_prio_id
        ORDER BY user_sequence ) LOOP

       l_cond := l_cond || GetOneRowCondition(
                  p_condition_id               => condition_rec.condition_id
                , p_array_cond_source_index    => p_array_cond_source_index
                , p_rec_sources                => p_rec_sources
               );
    END LOOP;

ELSIF p_segment_rule_detail_id IS NOT NULL THEN
-- ADR condition

  FOR condition_rec IN (
    SELECT   condition_id
           , user_sequence
      FROM    xla_conditions xc
     WHERE xc.application_id         = p_application_id
       AND xc.amb_context_code       = p_amb_context_code
       AND xc.segment_rule_detail_id = p_segment_rule_detail_id
     ORDER BY user_sequence ) LOOP

     l_cond := l_cond || GetOneRowCondition(
                  p_condition_id               => condition_rec.condition_id
                , p_array_cond_source_index    => p_array_cond_source_index
                , p_rec_sources                => p_rec_sources
               );
  END LOOP;

ELSIF  p_acctg_line_code         IS NOT NULL    AND
       p_acctg_line_type_code    IS NOT NULL    AND
       p_entity_code             IS NOT NULL    AND
       p_event_class_code        IS NOT NULL   THEN
-- Accounting line type condition

  FOR condition_rec IN (
     SELECT   condition_id
            , user_sequence
       FROM    xla_conditions xc
      WHERE xc.application_id   = p_application_id
        AND xc.amb_context_code = p_amb_context_code
        AND xc.accounting_line_code      = p_acctg_line_code
        AND xc.accounting_line_type_code = p_acctg_line_type_code
        AND xc.entity_code               = p_entity_code
        AND xc.event_class_code          = p_event_class_code
      ORDER BY user_sequence
  ) LOOP

     l_cond := l_cond || GetOneRowCondition(
                  p_condition_id               => condition_rec.condition_id
                , p_array_cond_source_index    => p_array_cond_source_index
                , p_rec_sources                => p_rec_sources
               );
  END LOOP;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
          (p_msg      => 'END of GetCondition'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;
RETURN l_cond;
EXCEPTION
WHEN VALUE_ERROR THEN
     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
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
         (p_location => 'xla_cmp_condition_pkg.GetCondition ');
END GetCondition;

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
--                               PACKAGE BODY
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
END xla_cmp_condition_pkg; --

/
