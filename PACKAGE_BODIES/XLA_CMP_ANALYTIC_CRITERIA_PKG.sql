--------------------------------------------------------
--  DDL for Package Body XLA_CMP_ANALYTIC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_ANALYTIC_CRITERIA_PKG" AS
/* $Header: xlacpanc.pkb 120.14 2005/07/12 22:27:11 awan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_analytic_criteria_pkg                                          |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate anlytical criteria from AMB specifcations                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     10-JAN-2003 K.Boussema  Created                                        |
|     14-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     01-APR-2003 K.Boussema    Included amb_context_code                    |
|                               update according to the new datamodel        |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143  |
|     17-JUL-2003 K.Boussema    Reviewed the code                            |
|     27-SEP-2003 K.Boussema    Changed the event_class clauses using '_ALL' |
|     10-OCT-2003 K.Boussema    Added an Outer join to query Anlytical       |
|                               criteria information, bug 3187719            |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     20-Sep-2004 S.Singhania Made ffg chagnes for the bulk changes:         |
|                               - Modified constant C_AC_HDR_CALL            |
|                               - Minor change to GenerateHdrAnalyticCriteria|
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A.Wan         Changed for MPA Bug 4262811                  |
+===========================================================================*/
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Constants/variables                                               |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
-- Analytical criteria defined in header
--
C_AC_HDR_CALL                   CONSTANT      VARCHAR2(10000):= '

xla_ae_header_pkg.g_rec_header_new.array_anc_id_$number$(hdr_idx) :=
xla_ae_header_pkg.SetAnalyticalCriteria(
   p_analytical_criterion_name    => ''$analytical_criterion_name$''
 , p_analytical_criterion_owner   => ''$analytical_criterion_owner$''
 , p_analytical_criterion_code    => ''$analytical_criterion_code$''
 , p_amb_context_code             => ''$amb_context_code$''
 , p_balancing_flag               => ''$balancing_flag$''
 $analytical_details$
)
;
--
';
--
--
-- Analytical criteria defined in line
--
C_AC_LINE_CALL                   CONSTANT      VARCHAR2(10000):= '

xla_ae_lines_pkg.g_rec_lines.array_anc_id_$number$(xla_ae_lines_pkg.g_LineNumber) :=
xla_ae_lines_pkg.SetAnalyticalCriteria(
   p_analytical_criterion_name    => ''$analytical_criterion_name$''
 , p_analytical_criterion_owner   => ''$analytical_criterion_owner$''
 , p_analytical_criterion_code    => ''$analytical_criterion_code$''
 , p_amb_context_code             => ''$amb_context_code$''
 , p_balancing_flag               => ''$balancing_flag$''
 $analytical_details$
 , p_ae_header_id                 => l_ae_header_id
)
;
--
';
--
--
C_DETAIL_CHAR                         CONSTANT VARCHAR2(10000):='
 , p_analytical_detail_char_$Jdx$    =>  TO_CHAR($detail_value$)
 , p_analytical_detail_num_$Jdx$     =>  NULL
 , p_analytical_detail_date_$Jdx$    =>  NULL
';
--
--
C_DETAIL_NUM                         CONSTANT VARCHAR2(10000):='
 , p_analytical_detail_char_$Jdx$    =>  NULL
 , p_analytical_detail_num_$Jdx$     =>  $detail_value$
 , p_analytical_detail_date_$Jdx$    =>  NULL
';
--
--
C_DETAIL_DATE                         CONSTANT VARCHAR2(10000):='
 , p_analytical_detail_char_$Jdx$    =>  NULL
 , p_analytical_detail_num_$Jdx$     =>  NULL
 , p_analytical_detail_date_$Jdx$    =>  $detail_value$
';
--
--
C_CHAR                         CONSTANT VARCHAR2(1):= 'C';
C_DATE                         CONSTANT VARCHAR2(1):= 'D';
C_NUM                          CONSTANT VARCHAR2(1):= 'N';
--
-- 4262811
C_LINE                         CONSTANT VARCHAR2(2):= 'L';
C_MPA_HDR                      CONSTANT VARCHAR2(2):= 'MH';
C_MPA_LINE                     CONSTANT VARCHAR2(2):= 'ML';

--+==========================================================================+
--|                                                                          |
--| Private global type declarations                                         |
--|                                                                          |
--+==========================================================================+
--
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
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
--                         FND trace
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_analytic_criteria_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 )
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
             (p_location   => 'xla_cmp_analytic_criteria_pkg.trace');
END trace;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GetAnalyticalCriteriaSources                                           |
|                                                                            |
|   Returns the list of sources defined the AMB header analytical criteria.  |
|                                                                            |
+---------------------------------------------------------------------------*/
PROCEDURE GetAnalyticalCriteriaSources (
    p_entity                       IN VARCHAR2
  , p_event_class                  IN VARCHAR2
  , p_event_type                   IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_product_rule_code            IN VARCHAR2
  , p_product_rule_type_code       IN VARCHAR2
  , p_amb_context_code             IN VARCHAR2
  , p_array_evt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
  , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
IS

CURSOR source_cur
IS
SELECT  DISTINCT
            xas.source_application_id
          , xas.source_type_code
          , xas.source_code
  FROM xla_analytical_sources   xas
     , xla_aad_header_ac_assgns xah
     , xla_analytical_hdrs_b    xahb
 WHERE  xas.analytical_criterion_code         = xah.analytical_criterion_code
   AND  xas.analytical_criterion_type_code    = xah.analytical_criterion_type_code
   AND  xas.amb_context_code                  = xah.amb_context_code
   AND  xas.analytical_criterion_code         = xahb.analytical_criterion_code
   AND  xas.analytical_criterion_type_code    = xahb.analytical_criterion_type_code
   AND  xas.amb_context_code                 = xahb.amb_context_code
   AND  xas.application_id                   = p_application_id
   AND  xas.entity_code                      = p_entity
   AND  xas.amb_context_code                 = p_amb_context_code
   AND (
        xas.event_class_code               = xah.event_class_code
        OR
        xas.event_class_code               = xas.entity_code ||'_ALL'
       )
   AND xah.event_class_code               = p_event_class
   AND xah.event_type_code                = p_event_type
   AND xas.source_application_id   IS NOT NULL
   AND xas.source_code             IS NOT NULL
   AND xas.source_type_code        IS NOT NULL
   AND xahb.enabled_flag           = 'Y'
   AND xah.product_rule_code       = p_product_rule_code
   AND xah.product_rule_type_code  = p_product_rule_type_code
ORDER BY xas.source_type_code, xas.source_code
;

l_SourceIdx                     BINARY_INTEGER;
l_source_application_id         xla_cmp_source_pkg.t_array_Num;
l_source_type_code              xla_cmp_source_pkg.t_array_VL1;
l_source_code                   xla_cmp_source_pkg.t_array_VL30;
l_log_module                    VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAnalyticalCriteriaSources';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetAnalyticalCriteriaSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'entity code = '||p_entity||
                        ' - event class code = '||p_event_class ||
                        ' - event type code = '||p_event_type||
                        ' - application id = '||p_application_id||
                        ' - product rule code = '||p_product_rule_code||
                        ' - product rule owner = '||p_product_rule_type_code||
                        ' amb context code =' ||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

OPEN source_cur;

FETCH source_cur BULK COLLECT INTO l_source_application_id
                                 , l_source_type_code
                                 , l_source_code
                                 ;

CLOSE source_cur;

IF l_source_code.EXISTS(NVL(l_source_code.FIRST,1)) THEN

   FOR Idx IN l_source_code.FIRST .. l_source_code.LAST LOOP

      l_SourceIdx := xla_cmp_source_pkg.StackSource (
                  p_source_code                => l_source_code(Idx)
                , p_source_type_code           => l_source_type_code(Idx)
                , p_source_application_id      => l_source_application_id(Idx)
                , p_array_source_index         => p_array_evt_source_index
                , p_rec_sources                => p_rec_sources
                );

   END LOOP;

END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetAnalyticalCriteriaSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RAISE;
   WHEN OTHERS    THEN
      IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.GetAnalyticalCriteriaSources');
END GetAnalyticalCriteriaSources;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Private Function                                                         |
|                                                                            |
|     HdrAnalyticCriteria                                                    |
|                                                                            |
|   Generates one header analytical criterion into PL/SQL code.              |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION HdrAnalyticCriteria(
  p_analytical_criterion_code      IN VARCHAR2
, p_analytical_criterion_type      IN VARCHAR2
, p_amb_context_code               IN VARCHAR2
, p_balancing_flag                 IN VARCHAR2
, p_criterion_value                IN VARCHAR2
, p_name                           IN VARCHAR2
, p_application_id                 IN NUMBER
, p_entity                         IN VARCHAR2
, p_event_class                    IN VARCHAR2
--
, p_rec_sources                    IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
CURSOR analytic_criteria_cur
IS
SELECT  xas.source_code
     ,  xas.source_type_code
     ,  xas.source_application_id
     ,  xadb.grouping_order
     ,  xadb.data_type_code
     ,  xadb.analytical_detail_code
  FROM  xla_analytical_dtls_b    xadb
      , xla_analytical_sources   xas
 WHERE  xadb.analytical_detail_code         = xas.analytical_detail_code
   AND  xadb.analytical_criterion_code      = xas.analytical_criterion_code
   AND  xadb.amb_context_code               = xas.amb_context_code
   AND  xadb.analytical_criterion_type_code = xas.analytical_criterion_type_code
   AND (
        xas.event_class_code                = p_event_class
       OR
        xas.event_class_code                = xas.entity_code ||'_ALL'
       )
   AND  xas.application_id                 = p_application_id
   AND  xas.entity_code                    = p_entity
   AND  xas.analytical_criterion_code       = p_analytical_criterion_code
   AND  xas.analytical_criterion_type_code  = p_analytical_criterion_type
   AND  xas.amb_context_code                = p_amb_context_code
   AND  xadb.analytical_detail_code        IS NOT NULL
   AND  xadb.data_type_code                IS NOT NULL
   AND  xadb.grouping_order                IS NOT NULL
 ORDER BY xadb.grouping_order
;
--
l_array_order                    xla_cmp_source_pkg.t_array_Num;
l_array_detail_code              xla_cmp_source_pkg.t_array_VL30;
l_array_data_type                xla_cmp_source_pkg.t_array_VL1;
l_array_source_code              xla_cmp_source_pkg.t_array_VL30;
l_array_source_type_code         xla_cmp_source_pkg.t_array_VL1;
l_array_source_appl_id           xla_cmp_source_pkg.t_array_Num;
--
l_source_Idx                     BINARY_INTEGER;
--
l_analytical_criteria            CLOB;
l_analytical_detail              CLOB;
l_detail                         VARCHAR2(32000);
l_log_module                     VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.HdrAnalyticCriteria';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of HdrAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'entity code = '||p_entity||
                        ' - event class code = '||p_event_class ||
                        ' - application id = '||p_application_id||
                        ' - analytical criterion code = '||p_analytical_criterion_code||
                        ' - analytical criterion owner = '||p_analytical_criterion_type||
                        ' amb context code =' ||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

OPEN analytic_criteria_cur;

FETCH analytic_criteria_cur BULK COLLECT INTO l_array_source_code
                                             ,l_array_source_type_code
                                             ,l_array_source_appl_id
                                             ,l_array_order
                                             ,l_array_data_type
                                             ,l_array_detail_code

;

CLOSE analytic_criteria_cur;

l_analytical_detail := NULL;

IF  l_array_detail_code.COUNT > 0 THEN

FOR Idx IN l_array_detail_code.FIRST .. l_array_detail_code.LAST LOOP
  IF l_array_detail_code.EXISTS(Idx) THEN

     CASE  l_array_data_type(Idx)
        WHEN C_NUM  THEN l_detail              := C_DETAIL_NUM;
        WHEN C_DATE THEN l_detail              := C_DETAIL_DATE;
        ELSE             l_detail              := C_DETAIL_CHAR;
    END CASE;

    l_detail              := REPLACE(l_detail,'$Jdx$',TO_CHAR(l_array_order(Idx)));

    IF l_array_source_code(Idx) IS NOT NULL THEN

         l_source_Idx := xla_cmp_source_pkg.CacheSource(
                               p_source_code           => l_array_source_code(Idx)
                             , p_source_type_code      => l_array_source_type_code(Idx)
                             , p_source_application_id => l_array_source_appl_id(Idx)
                             , p_rec_sources           => p_rec_sources
                              );

         l_detail := REPLACE(l_detail,'$detail_value$',
                           xla_cmp_source_pkg.GenerateSource(
                                 p_Index                     => l_source_Idx
                               , p_rec_sources               => p_rec_sources
                               , p_variable                  => 'H'
                               , p_translated_flag           => p_criterion_value)
                               );
    ELSE

         l_detail              := REPLACE(l_detail,'$detail_value$' , '''NULL''');

    END IF;

    l_analytical_detail := l_analytical_detail || l_detail ;

  END IF;

END LOOP;

l_analytical_criteria := C_AC_HDR_CALL ;
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_name$' ,REPLACE(p_name, '''',''''''));  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_owner$',p_analytical_criterion_type);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_code$' ,p_analytical_criterion_code);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$amb_context_code$'          ,p_amb_context_code);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$balancing_flag$'           ,p_balancing_flag);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_details$'
                            ,l_analytical_detail);

END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of HdrAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_analytical_criteria;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.HdrAnalyticCriteria');
END HdrAnalyticCriteria;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Private Function                                                         |
|                                                                            |
|     GenerateHdrAnalyticCriteria                                            |
|                                                                            |
|   Translates the AMB header analytical criteria into PL/SQL code.          |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateHdrAnalyticCriteria(
  p_application_id               IN NUMBER
, p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_entity                       IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
CURSOR analytic_criteria_cur
IS
SELECT DISTINCT
        xah.analytical_criterion_code
      , xah.analytical_criterion_type_code
      , xahb.balancing_flag
      , DECODE(xahb.criterion_value_code,
               'MEANING','Y'
              ,'N')
      , xaht.name
  FROM  xla_aad_header_ac_assgns  xah
     ,  xla_analytical_hdrs_b     xahb
     ,  xla_analytical_hdrs_tl    xaht
 WHERE  xah.analytical_criterion_code       = xahb.analytical_criterion_code
   AND  xah.analytical_criterion_type_code  = xahb.analytical_criterion_type_code
   AND  xah.amb_context_code                = xahb.amb_context_code
   AND  xah.analytical_criterion_code      = xaht.analytical_criterion_code (+)
   AND  xah.analytical_criterion_type_code = xaht.analytical_criterion_type_code (+)
   AND  xah.amb_context_code               = xaht.amb_context_code (+)
   AND  xah.application_id            = p_application_id
   AND  xah.product_rule_type_code    = p_product_rule_type_code
   AND  xah.product_rule_code         = p_product_rule_code
   AND  xah.amb_context_code          = p_amb_context_code
   AND  xah.event_class_code          = p_event_class
   AND  xah.event_type_code           = p_event_type
   AND  xahb.enabled_flag             = 'Y'
   AND  xaht.language(+)              = USERENV('LANG')
ORDER BY xah.analytical_criterion_type_code, xah.analytical_criterion_code
;
--
l_array_analytic_code                xla_cmp_source_pkg.t_array_VL30;
l_array_analytic_type_code           xla_cmp_source_pkg.t_array_VL1;
l_array_balancing_flag               xla_cmp_source_pkg.t_array_VL1;
l_array_name                         xla_cmp_source_pkg.t_array_VL80;
l_array_criterion_value              xla_cmp_source_pkg.t_array_VL1;
--
l_analytical_criteria                CLOB;
l_log_module                         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateHdrAnalyticCriteria';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateHdrAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'entity code = '||p_entity||
                        ' - event class code = '||p_event_class ||
                        ' - event type code = '||p_event_type||
                        ' - application id = '||p_application_id||
                        ' - product rule code = '||p_product_rule_code||
                        ' - product rule owner = '||p_product_rule_type_code||
                        ' amb context code =' ||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

OPEN analytic_criteria_cur;
--
FETCH analytic_criteria_cur BULK COLLECT INTO
                                  l_array_analytic_code
                                , l_array_analytic_type_code
                                , l_array_balancing_flag
                                , l_array_criterion_value
                                , l_array_name
                                ;
CLOSE analytic_criteria_cur;

l_analytical_criteria := NULL;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => '# number of analytical criteria = '||l_array_analytic_code.COUNT
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;

IF l_array_analytic_code.COUNT > 0 THEN

FOR Idx IN l_array_analytic_code.FIRST .. l_array_analytic_code.LAST LOOP

  IF l_array_analytic_code.EXISTS(Idx) THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
             (p_msg      => 'Analytical criteri name = '||l_array_name(Idx)
                           ||' - Analytical criteri code = '||l_array_analytic_code(Idx)
                           ||' - Analytical criteri type code = '||l_array_analytic_type_code(Idx)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
      END IF;

    l_analytical_criteria := l_analytical_criteria ||
    xla_cmp_string_pkg.replace_token(HdrAnalyticCriteria(  -- 4417664
      p_analytical_criterion_code  => l_array_analytic_code(Idx)
    , p_analytical_criterion_type  => l_array_analytic_type_code(Idx)
    , p_amb_context_code           => p_amb_context_code
    , p_balancing_flag             => l_array_balancing_flag(Idx)
    , p_criterion_value            => l_array_criterion_value(Idx)
    , p_name                       => l_array_name(Idx)
    , p_application_id             => p_application_id
    , p_entity                     => p_entity
    , p_event_class                => p_event_class
    , p_rec_sources                => p_rec_sources),'$number$',TO_CHAR(Idx));  -- 4417664


  END IF;

END LOOP;

END IF;

IF l_analytical_criteria IS NULL THEN
   l_analytical_criteria := '-- No header level analytical criteria';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of GenerateHdrAnalyticCriteria'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
RETURN l_analytical_criteria;
EXCEPTION
   WHEN VALUE_ERROR THEN
        -- SLA message to create
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;

        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= '||sqlerrm
                  ,p_level    => C_LEVEL_EXCEPTION
                  ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.GenerateHdrAnalyticCriteria');

END GenerateHdrAnalyticCriteria;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     LineAnalyticCriteria                                                   |
|                                                                            |
|   Translates one AMB line analytical criterion into PL/SQL code.           |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION LineAnalyticCriteria(
  p_analytical_criterion_code    IN VARCHAR2
, p_analytical_criterion_type    IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_balancing_flag               IN VARCHAR2
, p_criterion_value              IN VARCHAR2
, p_name                         IN VARCHAR2
, p_application_id               IN NUMBER
, p_event_class                  IN VARCHAR2
, p_ac_type                      IN VARCHAR2     -- 4262811
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
CURSOR analytic_criteria_cur
IS
SELECT  xas.source_code
     ,  xas.source_type_code
     ,  xas.source_application_id
     ,  xadb.grouping_order
     ,  xadb.data_type_code
     ,  xadb.analytical_detail_code
  FROM  xla_analytical_dtls_b    xadb
      , xla_analytical_sources   xas
 WHERE  xadb.analytical_detail_code         = xas.analytical_detail_code
   AND  xadb.analytical_criterion_code      = xas.analytical_criterion_code
   AND  xadb.analytical_criterion_type_code = xas.analytical_criterion_type_code
   AND  xadb.amb_context_code              = xas.amb_context_code
   AND (
        xas.event_class_code               = p_event_class
       OR
        xas.event_class_code               = xas.entity_code ||'_ALL'
       )
   AND  xas.analytical_criterion_code       = p_analytical_criterion_code
   AND  xas.analytical_criterion_type_code  = p_analytical_criterion_type
   AND  xas.amb_context_code               = p_amb_context_code
   AND  xas.application_id                 = p_application_id
   AND  xadb.analytical_detail_code        IS NOT NULL
   AND  xadb.data_type_code                IS NOT NULL
   AND  xadb.grouping_order                IS NOT NULL
 ORDER BY xadb.grouping_order
;
--
l_array_order                    xla_cmp_source_pkg.t_array_Num;
l_array_detail_code              xla_cmp_source_pkg.t_array_VL30;
l_array_data_type                xla_cmp_source_pkg.t_array_VL1;
l_array_source_code              xla_cmp_source_pkg.t_array_VL30;
l_array_source_type_code         xla_cmp_source_pkg.t_array_VL1;
l_array_source_appl_id           xla_cmp_source_pkg.t_array_Num;
--
l_source_Idx                     BINARY_INTEGER;
--
l_analytical_criteria            CLOB;
l_analytical_detail              CLOB;
l_detail                         VARCHAR2(32000);
l_log_module                     VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LineAnalyticCriteria';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LineAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' event class code = '||p_event_class ||
                        ' - application id = '||p_application_id||
                        ' - analytical criterion code = '||p_analytical_criterion_code||
                        ' - analytical criterion owner = '||p_analytical_criterion_type||
                        ' amb context code =' ||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

OPEN analytic_criteria_cur;
--
FETCH analytic_criteria_cur BULK COLLECT INTO l_array_source_code
                                             ,l_array_source_type_code
                                             ,l_array_source_appl_id
                                             ,l_array_order
                                             ,l_array_data_type
                                             ,l_array_detail_code
;
--
CLOSE analytic_criteria_cur;
--
l_analytical_detail := NULL;

IF l_array_detail_code.COUNT > 0 THEN

FOR Idx IN l_array_detail_code.FIRST .. l_array_detail_code.LAST LOOP

  IF l_array_detail_code.EXISTS(Idx) THEN

    CASE  l_array_data_type(Idx)
      WHEN C_NUM  THEN l_detail              := C_DETAIL_NUM;
      WHEN C_DATE THEN l_detail              := C_DETAIL_DATE;
      ELSE             l_detail              := C_DETAIL_CHAR;
    END CASE;

    l_detail              := REPLACE(l_detail,'$Jdx$', TO_CHAR(l_array_order(Idx)));

    IF l_array_source_code(Idx) IS NOT NULL THEN

         l_source_Idx := xla_cmp_source_pkg.StackSource (
                        p_source_code                => l_array_source_code(Idx)
                      , p_source_type_code           => l_array_source_type_code(Idx)
                      , p_source_application_id      => l_array_source_appl_id(Idx)
                      , p_array_source_index         => p_array_alt_source_index
                      , p_rec_sources                => p_rec_sources
                      );

         l_detail := REPLACE(l_detail,'$detail_value$',
                            xla_cmp_source_pkg.GenerateSource(
                                  p_Index             => l_source_Idx
                                , p_rec_sources       => p_rec_sources
                                , p_translated_flag   => p_criterion_value)
                                );
      ELSE

        l_detail              := REPLACE(l_detail,'$detail_value$' , '''NULL''');

      END IF;

    l_analytical_detail := l_analytical_detail || l_detail ;

  END IF;
END LOOP;

if p_ac_type = C_MPA_HDR THEN                -- 4262811
   l_analytical_criteria := C_AC_HDR_CALL;   -- 4262811
ELSE
   l_analytical_criteria := C_AC_LINE_CALL;
END IF;
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_name$' ,REPLACE(p_name, '''',''''''));  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_owner$',p_analytical_criterion_type);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_criterion_code$' ,p_analytical_criterion_code);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$amb_context_code$'          ,p_amb_context_code);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$balancing_flag$'           ,p_balancing_flag);  -- 4417664
l_analytical_criteria := xla_cmp_string_pkg.replace_token(l_analytical_criteria,'$analytical_details$'       ,
                            l_analytical_detail);

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of LineAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_analytical_criteria;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.LineAnalyticCriteria');
END LineAnalyticCriteria;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateMpaHeaderAC - 4262811                                          |
|                                                                            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateMpaHeaderAC(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accrual_jlt_owner_code       IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
CURSOR ac_cur IS
SELECT  xmhc.analytical_criterion_code
      , xmhc.analytical_criterion_type_code
      , xahb.balancing_flag
      , DECODE(xahb.criterion_value_code,
              'MEANING','Y'
              ,'N')
      , xaht.name
  FROM  xla_mpa_header_ac_assgns  xmhc
     ,  xla_analytical_hdrs_b     xahb
     ,  xla_analytical_hdrs_tl    xaht
 WHERE  xahb.analytical_criterion_code      = xaht.analytical_criterion_code (+)
   AND  xahb.analytical_criterion_type_code = xaht.analytical_criterion_type_code(+)
   AND  xahb.amb_context_code               = xaht.amb_context_code (+)
   AND  xaht.language(+)                    = USERENV('LANG')
   AND  xmhc.analytical_criterion_code      = xahb.analytical_criterion_code
   AND  xmhc.analytical_criterion_type_code = xahb.analytical_criterion_type_code
   AND  xmhc.amb_context_code               = xahb.amb_context_code
   AND  xmhc.application_id                 = p_application_id
   AND  xmhc.amb_context_code               = p_amb_context_code
   AND  xmhc.event_class_code               = p_event_class
   AND  xmhc.event_type_code                = p_event_type
   AND  xmhc.line_definition_owner_code     = p_line_definition_owner_code
   AND  xmhc.line_definition_code           = p_line_definition_code
   AND  xmhc.accounting_line_type_code      = p_accrual_jlt_owner_code
   AND  xmhc.accounting_line_code           = p_accrual_jlt_code
   AND  xahb.enabled_flag                   = 'Y'
ORDER BY xmhc.analytical_criterion_type_code, xmhc.analytical_criterion_code
;

l_array_ac_code                      xla_cmp_source_pkg.t_array_VL30;
l_array_ac_type_code                 xla_cmp_source_pkg.t_array_VL1;
l_array_balancing_flag               xla_cmp_source_pkg.t_array_VL1;
l_array_ac_value                     xla_cmp_source_pkg.t_array_VL1;
l_array_name                         xla_cmp_source_pkg.t_array_VL80;

l_body          CLOB;
l_log_module    VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateMpaHeaderAC';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateMpaHeaderAC'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;


OPEN ac_cur;
FETCH ac_cur BULK COLLECT INTO
                                  l_array_ac_code
                                , l_array_ac_type_code
                                , l_array_balancing_flag
                                , l_array_ac_value
                                , l_array_name;
CLOSE ac_cur;
--
IF l_array_ac_code.COUNT > 0 THEN
   --
   l_body := 'hdr_idx := g_last_hdr_idx;  -- to set value of mpa header index for analytical criteria
             ';
   --
   FOR Idx IN l_array_ac_code.FIRST .. l_array_ac_code.LAST LOOP
      --
      IF l_array_ac_code.EXISTS(Idx) THEN
         --
         l_body := l_body ||xla_cmp_string_pkg.replace_token(LineAnalyticCriteria(
                                         p_analytical_criterion_code            => l_array_ac_code(Idx)
                                       , p_analytical_criterion_type            => l_array_ac_type_code(Idx)
                                       , p_amb_context_code                     => p_amb_context_code
                                       , p_balancing_flag                       => l_array_balancing_flag(Idx)
                                       , p_criterion_value                      => l_array_ac_value(Idx)
                                       , p_name                                 => l_array_name(Idx)
                                       , p_application_id                       => p_application_id
                                       , p_event_class                          => p_event_class
                                       , p_ac_type                              => C_MPA_HDR
                                       , p_array_alt_source_index               => p_array_alt_source_index
                                       , p_rec_sources                          => p_rec_sources
                                       ) ,'$number$',TO_CHAR(Idx));
         --
      END IF;
      --
   END LOOP;
  --
END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateMpaHeaderAC'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_body;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF ac_cur%ISOPEN THEN CLOSE ac_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF ac_cur%ISOPEN THEN CLOSE ac_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.GenerateMpaHeaderAC');

END GenerateMpaHeaderAC;


/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateMpaLineAC   - 4262811                                          |
|                                                                            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateMpaLineAC(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accrual_jlt_owner_code       IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
, p_mpa_jlt_owner_code           IN VARCHAR2
, p_mpa_jlt_code                 IN VARCHAR2
, p_array_mpa_jlt_source_index   IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS

CURSOR ac_cur IS
SELECT  xmlc.analytical_criterion_code
      , xmlc.analytical_criterion_type_code
      , xahb.balancing_flag
      , DECODE(xahb.criterion_value_code,
              'MEANING','Y'
              ,'N')
      , xaht.name
  FROM  xla_mpa_jlt_ac_assgns    xmlc
     ,  xla_analytical_hdrs_b     xahb
     ,  xla_analytical_hdrs_tl    xaht
 WHERE  xahb.analytical_criterion_code      = xaht.analytical_criterion_code (+)
   AND  xahb.analytical_criterion_type_code = xaht.analytical_criterion_type_code(+)
   AND  xahb.amb_context_code               = xaht.amb_context_code (+)
   AND  xaht.language(+)                    = USERENV('LANG')
   AND  xmlc.analytical_criterion_code      = xahb.analytical_criterion_code
   AND  xmlc.analytical_criterion_type_code = xahb.analytical_criterion_type_code
   AND  xmlc.amb_context_code               = xahb.amb_context_code
   AND  xmlc.application_id                 = p_application_id
   AND  xmlc.amb_context_code               = p_amb_context_code
   AND  xmlc.event_class_code               = p_event_class
   AND  xmlc.event_type_code                = p_event_type
   AND  xmlc.line_definition_owner_code     = p_line_definition_owner_code
   AND  xmlc.line_definition_code           = p_line_definition_code
   AND  xmlc.accounting_line_type_code      = p_accrual_jlt_owner_code
   AND  xmlc.accounting_line_code           = p_accrual_jlt_code
   AND  xmlc.mpa_accounting_line_type_code  = p_mpa_jlt_owner_code
   AND  xmlc.mpa_accounting_line_code       = p_mpa_jlt_code
   AND  xahb.enabled_flag                   = 'Y'
ORDER BY xmlc.analytical_criterion_type_code, xmlc.analytical_criterion_code
;
--
l_array_ac_code                      xla_cmp_source_pkg.t_array_VL30;
l_array_ac_type_code                 xla_cmp_source_pkg.t_array_VL1;
l_array_balancing_flag               xla_cmp_source_pkg.t_array_VL1;
l_array_ac_value                     xla_cmp_source_pkg.t_array_VL1;
l_array_name                         xla_cmp_source_pkg.t_array_VL80;

l_body         CLOB;
l_log_module   VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateMpaLineAC';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateMpaLineAC'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

OPEN ac_cur;
FETCH ac_cur BULK COLLECT INTO    l_array_ac_code
                                , l_array_ac_type_code
                                , l_array_balancing_flag
                                , l_array_ac_value
                                , l_array_name;
CLOSE ac_cur;
--
l_body := NULL;
--
IF l_array_ac_code.COUNT > 0 THEN
  --
  FOR Idx IN l_array_ac_code.FIRST .. l_array_ac_code.LAST LOOP
  --
    IF l_array_ac_code.EXISTS(Idx) THEN
       --
       l_body := l_body ||xla_cmp_string_pkg.replace_token(LineAnalyticCriteria(
                                                p_analytical_criterion_code     => l_array_ac_code(Idx)
                                              , p_analytical_criterion_type     => l_array_ac_type_code(Idx)
                                              , p_amb_context_code              => p_amb_context_code
                                              , p_balancing_flag                => l_array_balancing_flag(Idx)
                                              , p_criterion_value               => l_array_ac_value(Idx)
                                              , p_name                          => l_array_name(Idx)
                                              , p_application_id                => p_application_id
                                              , p_event_class                   => p_event_class
                                              , p_ac_type                       => C_MPA_LINE
                                              , p_array_alt_source_index        => p_array_mpa_jlt_source_index
                                              , p_rec_sources                   => p_rec_sources
                                              ) ,'$number$',TO_CHAR(Idx));
       --
    END IF;
    --
  END LOOP;
  --
END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateMpaLineAC'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_body;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF ac_cur%ISOPEN THEN CLOSE ac_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF ac_cur%ISOPEN THEN CLOSE ac_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.GenerateMpaLineAC');

END GenerateMpaLineAC;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateLineAnalyticCriteria                                           |
|                                                                            |
|   Translates the AMB line analytical criteria into PL/SQL code.            |
|                                                                            |
+---------------------------------------------------------------------------*/


FUNCTION GenerateLineAnalyticCriteria(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
--
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
CURSOR analytic_criteria_cur
IS
SELECT  xlda.analytical_criterion_code
      , xlda.analytical_criterion_type_code
      , xahb.balancing_flag
      , DECODE(xahb.criterion_value_code,
              'MEANING','Y'
              ,'N')
      , xaht.name
  FROM  xla_line_defn_ac_assgns   xlda
     ,  xla_analytical_hdrs_b     xahb
     ,  xla_analytical_hdrs_tl    xaht
 WHERE  xahb.analytical_criterion_code      = xaht.analytical_criterion_code (+)
   AND  xahb.analytical_criterion_type_code = xaht.analytical_criterion_type_code (+)
   AND  xahb.amb_context_code               = xaht.amb_context_code (+)
   AND  xaht.language(+)                    = USERENV('LANG')
   AND  xlda.analytical_criterion_code      = xahb.analytical_criterion_code
   AND  xlda.analytical_criterion_type_code = xahb.analytical_criterion_type_code
   AND  xlda.amb_context_code               = xahb.amb_context_code
   AND  xlda.application_id                 = p_application_id
   AND  xlda.amb_context_code               = p_amb_context_code
   AND  xlda.event_class_code               = p_event_class
   AND  xlda.event_type_code                = p_event_type
   AND  xlda.line_definition_owner_code     = p_line_definition_owner_code
   AND  xlda.line_definition_code           = p_line_definition_code
   AND  xlda.accounting_line_code           = p_accounting_line_code
   AND  xlda.accounting_line_type_code      = p_accounting_line_type_code
   AND  xahb.enabled_flag                   = 'Y'
ORDER BY xlda.analytical_criterion_type_code, xlda.analytical_criterion_code
;
--
l_array_analytic_code                xla_cmp_source_pkg.t_array_VL30;
l_array_analytic_type_code           xla_cmp_source_pkg.t_array_VL1;
l_array_balancing_flag               xla_cmp_source_pkg.t_array_VL1;
l_array_name                         xla_cmp_source_pkg.t_array_VL80;
l_array_criterion_value              xla_cmp_source_pkg.t_array_VL1;
--
l_analytical_criteria                CLOB;
l_log_module                         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLineAnalyticCriteria';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLineAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' event class code = '||p_event_class ||
                        ' - event type code = '||p_event_type||
                        ' - application id = '||p_application_id||
                        ' - line definition code = '||p_line_definition_code||
                        ' - line definition owner = '||p_line_definition_owner_code||
                        ' - accounting line code = '||p_accounting_line_code||
                        ' - accounting line owner = '||p_accounting_line_type_code||
                        ' amb context code =' ||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


OPEN analytic_criteria_cur;

FETCH analytic_criteria_cur BULK COLLECT INTO
                                  l_array_analytic_code
                                , l_array_analytic_type_code
                                , l_array_balancing_flag
                                , l_array_criterion_value
                                , l_array_name
                                ;
CLOSE analytic_criteria_cur;

l_analytical_criteria := NULL;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'l_array_analytic_code.COUNT = '||l_array_analytic_code.COUNT
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;

IF l_array_analytic_code.COUNT > 0 THEN

FOR Idx IN l_array_analytic_code.FIRST .. l_array_analytic_code.LAST LOOP

  IF l_array_analytic_code.EXISTS(Idx) THEN

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
             (p_msg      => 'Analytical criteri name = '||l_array_name(Idx)
                            ||' - Analytical criteri code = '||l_array_analytic_code(Idx)
                            ||' - Analytical criteri type code = '||l_array_analytic_type_code(Idx)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
     END IF;

    l_analytical_criteria := l_analytical_criteria ||
    xla_cmp_string_pkg.replace_token(   -- 4417664
     LineAnalyticCriteria(
      p_analytical_criterion_code            => l_array_analytic_code(Idx)
    , p_analytical_criterion_type            => l_array_analytic_type_code(Idx)
    , p_amb_context_code                     => p_amb_context_code
    , p_balancing_flag                       => l_array_balancing_flag(Idx)
    , p_criterion_value                      => l_array_criterion_value(Idx)
    , p_name                                 => l_array_name(Idx)
    , p_application_id                       => p_application_id
    , p_event_class                          => p_event_class
    , p_ac_type                              => C_LINE             -- 4262811
    , p_array_alt_source_index               => p_array_alt_source_index
    , p_rec_sources                          => p_rec_sources ) ,'$number$',  TO_CHAR(Idx));  -- 4417664

  END IF;
END LOOP;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLineAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_analytical_criteria;
EXCEPTION
   WHEN VALUE_ERROR THEN
        --
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;

        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR ='||sqlerrm
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF analytic_criteria_cur%ISOPEN THEN CLOSE analytic_criteria_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_analytic_criteria_pkg.GenerateLineAnalyticCriteria');

END GenerateLineAnalyticCriteria;

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

END xla_cmp_analytic_criteria_pkg; --

/
