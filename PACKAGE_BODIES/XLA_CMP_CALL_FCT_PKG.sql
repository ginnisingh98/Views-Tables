--------------------------------------------------------
--  DDL for Package Body XLA_CMP_CALL_FCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_CALL_FCT_PKG" AS
/* $Header: xlacpcll.pkb 120.19 2006/04/06 19:39:58 wychan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_call_fct_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate function/procedure calls                                   |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema  Created                                        |
|     20-FEB-2003 K.Boussema  Added 'dbdrv' command                          |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     20-Sep-2004 S.Singhania   Made ffg chganges for the BULK performance   |
|                                 - Modifed routines GenerateCallHdrDescALT, |
|                                   GetHeaderParameters, GetLineParameters,  |
|                                   GenerateCallHeaderDesc, GenerateCallLineD|
|                                   esc, GenerateCallAcctLineType            |
|                                 - Replaced LONG with CLOB                  |
|                                 - xla_cmp_string_pkg.replace_token was used|
|                                   to perform REPLACE on CLOB variables.    |
|     21-Sep-2004 S.Singhania   Added NOCOPY hint to the OUT parameters.     |
|     28-Feb-2005 W. Shen       change made for ledger currency project      |
|                                 GenerateCallADR                            |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_call_fct_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2)
IS
BEGIN
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
             (p_location   => 'xla_cmp_call_fct_pkg.trace');
END trace;


/*-----------------------------------------------------------------+
|                                                                  |
|   Public Function                                                |
|                                                                  |
|   GetSourceParameters                                            |
|                                                                  |
|   Generates the source parameters in function/procedure call     |
|                                                                  |
|   Example: p_source_1 => p_source_1,                             |
|            p_source_2 => p_source_2, ...                         |
|            p_source_2_meaning => p_source_2_meaning, ...         |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetSourceParameters(
  p_array_source_index    IN xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources          IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
--
C_PARAMETER        CONSTANT VARCHAR2(1000) := ', p_source_$Index$ => p_source_$Index$';
C_MNG_PARAMETER    CONSTANT VARCHAR2(1000) := ', p_source_$Index$_meaning => p_source_$Index$_meaning';
--
l_parameters       CLOB;
l_one_param        VARCHAR2(10000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSourceParameters';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetSourceParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_array_source_index.COUNT = '||p_array_source_index.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_parameters :=  NULL;

IF p_array_source_index.COUNT > 0 THEN

FOR Idx IN p_array_source_index.FIRST ..  p_array_source_index.LAST LOOP
  IF  p_array_source_index.EXISTS(Idx) THEN

       l_one_param  := C_PARAMETER;

       IF p_rec_sources.array_lookup_type.EXISTS(Idx)
       AND  p_rec_sources.array_lookup_type(Idx) IS NOT NULL
       AND  p_rec_sources.array_view_application_id.EXISTS(Idx)
       AND  p_rec_sources.array_view_application_id(Idx) IS NOT NULL THEN

         l_one_param  := l_one_param || g_chr_newline || C_MNG_PARAMETER;

    END IF;

    l_one_param  := REPLACE(l_one_param,'$Index$',Idx) ;
    l_parameters := l_parameters || g_chr_newline || l_one_param ;

  END IF;
END LOOP;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetSourceParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_parameters;
EXCEPTION
   WHEN VALUE_ERROR THEN
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
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_call_fct_pkg.GetSourceParameters');
END GetSourceParameters;

/*-----------------------------------------------------------------+
|                                                                  |
|   Public Function                                                |
|                                                                  |
|   GetHeaderParameters                                            |
|                                                                  |
|   Generates the source parameters in header fct/prod call        |
|                                                                  |
|   Example: p_source_1 => l_source_1,                             |
|            p_source_2 => l_source_2, ...                         |
|            p_source_2_meaning => l_source_2_meaning, ...         |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetHeaderParameters(
  p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
C_PARAMETER        CONSTANT VARCHAR2(2000) :=
' , p_source_$Index$ => g_array_event(l_event_id).array_value_$datatype$(''source_$Index$'')';
C_MNG_PARAMETER    CONSTANT VARCHAR2(2000) :=
' , p_source_$Index$_meaning => g_array_event(l_event_id).array_value_char(''source_$Index$_meaning'')';

l_parameters       CLOB;
l_one_param        VARCHAR2(10000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetHeaderParameters';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetHeaderParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_parameters :=  NULL;

IF p_array_source_index.COUNT >  0 THEN
FOR Idx IN p_array_source_index.FIRST ..  p_array_source_index.LAST LOOP

  IF  p_array_source_index.EXISTS(Idx) THEN

    l_one_param  := C_PARAMETER;

    IF p_rec_sources.array_lookup_type.EXISTS(Idx) AND
       p_rec_sources.array_lookup_type(Idx) IS NOT NULL AND
       p_rec_sources.array_view_application_id.EXISTS(Idx) AND
       p_rec_sources.array_view_application_id(Idx) IS NOT NULL THEN

        l_one_param  := l_one_param || g_chr_newline || C_MNG_PARAMETER;

    END IF;

    l_one_param  := REPLACE(l_one_param,'$Index$',Idx) ;

    CASE p_rec_sources.array_datatype_code(Idx)

        WHEN 'I' then
              l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
        WHEN 'F' then
              l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
        WHEN 'N' then
              l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
        WHEN 'C' then
              l_one_param  := REPLACE(l_one_param,'$datatype$','char') ;
        WHEN 'D' then
              l_one_param  := REPLACE(l_one_param,'$datatype$','date') ;
        ELSE
              l_one_param  := REPLACE(l_one_param,'$datatype$',p_rec_sources.array_datatype_code(Idx)) ;
     END CASE;

     l_parameters := l_parameters ||g_chr_newline|| l_one_param ;

  END IF;
END LOOP;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetHeaderParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_parameters;
EXCEPTION
   WHEN VALUE_ERROR THEN
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
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_call_fct_pkg.GetHeaderParameters');
END GetHeaderParameters;

/*--------------------------------------------------------------------------+
|                                                                           |
|   Public Function                                                         |
|                                                                           |
|   GetLineParameters                                                       |
|                                                                           |
|   Generates the source parameters in line fct/prod call                   |
|                                                                           |
|   Example: p_source_1 => l_array_source_1(Idx),                           |
|   p_source_1_meaning => l_array_source_1_meaning(Idx),                    |
|  p_source_2 => g_array_event(l_event_id).array_value_num('source_1'), ... |
|                                                                           |
+--------------------------------------------------------------------------*/

FUNCTION GetLineParameters(
   p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
 , p_array_source_level           IN xla_cmp_source_pkg.t_array_VL1
 , p_rec_sources                  IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS

C_L_PARAMETER      CONSTANT VARCHAR2(1000) :=
' , p_source_$Index$ => l_array_source_$Index$(Idx)';
C_L_MNG_PARAMETER  CONSTANT VARCHAR2(1000) :=
' , p_source_$Index$_meaning => l_array_source_$Index$_meaning(Idx)';
C_H_PARAMETER      CONSTANT VARCHAR2(1000) :=
' , p_source_$Index$ => g_array_event(l_event_id).array_value_$datatype$(''source_$Index$'')';
C_H_MNG_PARAMETER  CONSTANT VARCHAR2(1000) :=
' , p_source_$Index$_meaning => g_array_event(l_event_id).array_value_char(''source_$Index$_meaning'')';
--
l_parameters       CLOB;
l_one_param        VARCHAR2(32000) ;
l_log_module       VARCHAR2(240);
invalid_source     EXCEPTION;
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLineParameters';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetLineParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_parameters :=  NULL;

IF p_array_source_index.COUNT > 0 THEN

FOR Idx IN p_array_source_index.FIRST ..  p_array_source_index.LAST LOOP

  IF  p_array_source_index.EXISTS(Idx) AND
      p_array_source_level.EXISTS(Idx) THEN

    IF p_array_source_level(Idx) ='H' THEN

      l_one_param  := C_H_PARAMETER;

      IF p_rec_sources.array_lookup_type.EXISTS(Idx) AND
         p_rec_sources.array_lookup_type(Idx) IS NOT NULL AND
         p_rec_sources.array_view_application_id.EXISTS(Idx) AND
         p_rec_sources.array_view_application_id(Idx) IS NOT NULL THEN

         l_one_param  := l_one_param || g_chr_newline || C_H_MNG_PARAMETER;

      END IF;

    ELSIF p_array_source_level(Idx) ='L' THEN
    --
      l_one_param  := C_L_PARAMETER;

      IF p_rec_sources.array_lookup_type.EXISTS(Idx) AND
         p_rec_sources.array_lookup_type(Idx) IS NOT NULL AND
         p_rec_sources.array_view_application_id.EXISTS(Idx) AND
         p_rec_sources.array_view_application_id(Idx) IS NOT NULL THEN

         l_one_param  := l_one_param || g_chr_newline || C_L_MNG_PARAMETER;

      END IF;

    ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||
                              ' invalid source level : header source nor line source ='||
                              p_rec_sources.array_source_code(Idx) ||' - '||
                              p_rec_sources.array_source_type_code(Idx) ||' - '||
                              p_rec_sources.array_application_id(Idx)
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE invalid_source;
    END IF;
    --
    l_one_param  := REPLACE(l_one_param,'$Index$',Idx) ;

    case p_rec_sources.array_datatype_code(Idx)
    when 'F' then
       l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
    when 'N' then
       l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
    when 'I' then
       l_one_param  := REPLACE(l_one_param,'$datatype$','num') ;
    when 'C' then
       l_one_param  := REPLACE(l_one_param,'$datatype$','char') ;
    when 'D' then
       l_one_param  := REPLACE(l_one_param,'$datatype$','date') ;
    else
       l_one_param  := REPLACE(l_one_param,'$datatype$',p_rec_sources.array_datatype_code(Idx)) ;
    end case;

    l_parameters := l_parameters || g_chr_newline||  l_one_param ;

  END IF;
END LOOP;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetLineParameters'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_parameters;
EXCEPTION
   WHEN invalid_source THEN
      RAISE;
   WHEN VALUE_ERROR THEN
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
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_call_fct_pkg.GetLineParameters');
END GetLineParameters;

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

END xla_cmp_call_fct_pkg; --

/
