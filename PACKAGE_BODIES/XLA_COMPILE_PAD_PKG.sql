--------------------------------------------------------
--  DDL for Package Body XLA_COMPILE_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_COMPILE_PAD_PKG" AS
/* $Header: xlacpcmp.pkb 120.9 2005/04/28 18:43:40 masada ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_compile_pad_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for compilation of Product Accounting definition                       |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     15-JUL-2002 K.Boussema    Created                                      |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     27-MAR-2003 K.Boussema    changed package name xla_compile_pkg by      |
|                               xla_compile_pad_pkg                          |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
+===========================================================================*/

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_compile_pad_pkg';

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
             (p_location   => 'xla_compile_pad_pkg.trace');
END trace;


--+==========================================================================+
--| PUBLIC procedures and functions                                          |
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

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_compile_status                                                    |
|                                                                       |
| Return                                                                |
|             status                                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_compile_status( p_application_id         IN NUMBER
                            , p_product_rule_code      IN VARCHAR2
                            , p_product_rule_type_code IN VARCHAR2
                            , p_amb_context_code       IN VARCHAR2
                            )
RETURN VARCHAR2
IS
--
l_status             VARCHAR2(1);
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_compile_status';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_compile_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => ' SQL - Select from xla_product_rules_b'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
SELECT compile_status_code
INTO   l_status
FROM   xla_product_rules_b
WHERE  application_id            = p_application_id
  AND  product_rule_code         = p_product_rule_code
  AND  product_rule_type_code    = p_product_rule_type_code
  AND  nvl(amb_context_code,'@') = nvl(p_amb_context_code,'@')
;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||l_status
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of get_compile_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_status;
--
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_compile_pad_pkg.get_compile_status');
END get_compile_status;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| setstatus                                                             |
|                                                                       |
| Switch the compile flag                                               |
|                                                                       |
| Parameters                                                            |
|             1      p_application_id         NUMBER                    |
|             2      p_product_rule_code      VARCHAR2                  |
|             3      p_product_rule_type_code VARCHAR2                  |
|             4      p_compile_old            VARCHAR2 Old status       |
|             5      p_compile_old            VARCHAR2 New status       |
|                                                                       |
+======================================================================*/

PROCEDURE set_compile_status    (p_application_id               IN  NUMBER
                                ,p_product_rule_code            IN  VARCHAR2
                                ,p_product_rule_type_code       IN  VARCHAR2
                                ,p_amb_context_code             IN  VARCHAR2
                                ,p_status_old                   IN  VARCHAR2
                                ,p_status_new                   IN  VARCHAR2)
IS

l_rows               NUMBER;
l_status             VARCHAR2(1);
l_log_module         VARCHAR2(240);

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_compile_status';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of set_compile_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
UPDATE  xla_product_rules_b
SET     compile_status_code      = p_status_new
WHERE   compile_status_code      = NVL(p_status_old, compile_status_code)
  AND   application_id           = p_application_id
  AND   product_rule_code        = p_product_rule_code
  AND   product_rule_type_code   = p_product_rule_type_code
  AND  nvl(amb_context_code,'@') = nvl(p_amb_context_code,'@')
;

l_rows   := SQL%ROWCOUNT;

IF l_rows = 0 THEN
   --

   l_status := get_compile_status( p_application_id
                                 , p_product_rule_code
                                 , p_product_rule_type_code
                                 , p_amb_context_code
                                );


   --
    xla_exceptions_pkg.raise_message
                                         ('XLA'
                                         ,'XLA_CMP_COMPILER_ERROR'
                                         ,'PROCEDURE'
                                         ,'xla_compile_pad_pkg.set_compile_status'
                                         ,'ERROR'
                                         ,'INVALID COMPILER STATUS'
                                  );

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => '< END  xla_compile_pad_pkg.set_compile_status'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_compile_pad_pkg.set_compile_status');
END set_compile_status;
--
--
/*======================================================================+
|                                                                       |
| Public  Procedure                                                     |
|                                                                       |
| compile_pad                                                           |
|                                                                       |
| Run PAD compilation                                                   |
|                                                                       |
+======================================================================*/
FUNCTION CompileProductRule(
                       p_application_id            IN NUMBER
                     , p_product_rule_code         IN VARCHAR2
                     , p_product_rule_type_code    IN VARCHAR2
                     , p_product_rule_version      IN VARCHAR2
                     , p_amb_context_code          IN VARCHAR2
                    )
RETURN BOOLEAN
IS
l_compile_flag       BOOLEAN;
l_status             VARCHAR2(1);
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CompileProductRule';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CompileProductRule'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_product_rule_type_code = '||p_product_rule_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_product_rule_version = '||p_product_rule_version
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

--
l_status := get_compile_status(  p_application_id          => p_application_id
                               , p_product_rule_code       => p_product_rule_code
                               , p_product_rule_type_code  => p_product_rule_type_code
                               , p_amb_context_code        => p_amb_context_code
                              );
--
-- if compilation is running for PAD
--
IF l_status = 'R' THEN
   --
   l_compile_flag:= xla_cmp_pad_pkg.Compile(
                                 p_application_id          => p_application_id
                               , p_product_rule_code       => p_product_rule_code
                               , p_product_rule_type_code  => p_product_rule_type_code
                               , p_product_rule_version    => p_product_rule_version
                               , p_amb_context_code        => p_amb_context_code
                              );
   --
ELSE
   --
   -- Invalid compile status, status expexted: R,
   --
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR'
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
   END IF;
   --
   xla_exceptions_pkg.raise_message
                                   ('XLA'
                                   ,'XLA_CMP_COMPILER_ERROR'
                                   ,'PROCEDURE'
                                   ,'xla_compile_pad_pkg.CompileProductRule'
                                   ,'ERROR'
                                   ,'INVALID COMPILER STATUS'
                                   );

   l_compile_flag:= FALSE;
   --
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of CompileProductRule'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_compile_flag;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        l_compile_flag:= FALSE;
        RETURN l_compile_flag;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_compile_pad_pkg.CompileProductRule');
END CompileProductRule;
--
--
/*======================================================================+
|                                                                       |
| Public function                                                       |
|                                                                       |
| compile                                                               |
|                                                                       |
| Run the global compile                                                |
|                                                                       |
+======================================================================*/
FUNCTION Compile(  p_application_id            IN NUMBER
                 , p_product_rule_code         IN VARCHAR2
                 , p_product_rule_type_code    IN VARCHAR2
                 , p_product_rule_version      IN VARCHAR2
                 , p_amb_context_code          IN VARCHAR2 )
RETURN BOOLEAN
IS
--
l_compile_flag        BOOLEAN:=FALSE;
l_log_module          VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Compile';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of Compile'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_compile_flag := CompileProductRule (
                                p_application_id          => p_application_id
                              , p_product_rule_code       => p_product_rule_code
                              , p_product_rule_type_code  => p_product_rule_type_code
                              , p_product_rule_version    => p_product_rule_version
                              , p_amb_context_code        => p_amb_context_code
                              );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of Compile'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_compile_flag;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
   WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_compile_pad_pkg.Compile');
END Compile;
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
END xla_compile_pad_pkg; -- end of package spec

/
