--------------------------------------------------------
--  DDL for Package Body XLA_FA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_FA_EXTRACT_PKG" AS
-- $Header: xlafaext.pkb 120.2 2006/03/17 21:26:52 svjoshi noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_fa_extract_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     SLA wrapper package for FA dynamic extract.                            |
|                                                                            |
| HISTORY                                                                    |
|     03/06/2006    Shishir Joshi   Created                                  |
|                                                                            |
+===========================================================================*/

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_fa_extract_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace (p_msg          IN VARCHAR2
                ,p_level        IN NUMBER
                ,p_module       IN VARCHAR2) IS
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
         (p_location   => 'xla_fa_extract_pkg.trace');
END trace;


PROCEDURE COMPILE
   (p_application_id           IN INTEGER
   ,p_amb_context_code         IN VARCHAR2
   ,p_product_rule_type_code   IN VARCHAR2
   ,p_product_rule_code        IN VARCHAR2) IS
l_log_module         VARCHAR2(240);
l_sqlerrm            VARCHAR2(2000);
BEGIN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg    =>  'BEGIN of procedure Compile'
         ,p_level  =>  C_LEVEL_PROCEDURE
         ,p_module =>  l_log_module);
   END IF;

   -- Call Product API
   IF p_application_id = 140 THEN
      xla_utility_pkg.print_logfile
         ('Calling fa_xla_cmp_accounting_pkg');
      fa_xla_cmp_accounting_pkg.compile;
   END IF;

   --

EXCEPTION
   WHEN OTHERS THEN
      l_sqlerrm := sqlerrm;

      IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
         trace
            (p_msg      => 'Technical problem : Error encountered in fa_xla_cmp_accounting_pkg '||
                           xla_environment_pkg.g_chr_newline||l_sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
      END IF;
   	xla_utility_pkg.print_logfile('Technical problem: Error encountered in product API fa_xla_cmp_accounting_pkg' || l_sqlerrm);
      RAISE;
END Compile;


BEGIN
--   l_log_module     := C_DEFAULT_MODULE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_fa_extract_pkg; -- end of package spec.

/
