--------------------------------------------------------
--  DDL for Package Body XLA_TAB_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TAB_PUB_PKG" AS
/* $Header: xlatbpub.pkb 120.1 2005/04/28 18:45:43 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_pub_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder API Compiler                           |
|                                                                       |
| HISTORY                                                               |
|                                                                       |
|    27-AUG-02 A. Quaglia     Created                                   |
|                                                                       |
+======================================================================*/


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_tab_pub_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
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
         (p_location   => 'xla_tab_pub_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| run                                                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE run
          (
            p_api_version                  IN NUMBER
           ,p_application_id               IN NUMBER
           ,p_account_definition_type_code IN VARCHAR2
           ,p_account_definition_code      IN VARCHAR2
           ,p_transaction_coa_id           IN NUMBER
           ,p_mode                         IN VARCHAR2
           ,x_return_status                OUT NOCOPY VARCHAR2
           ,x_msg_count                    OUT NOCOPY NUMBER
           ,x_msg_data                     OUT NOCOPY VARCHAR2
          )
IS
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_log_module          VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.run';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   xla_tab_pkg.run
         (
            p_api_version                  => p_api_version
           ,p_application_id               => p_application_id
           ,p_account_definition_type_code => p_account_definition_type_code
           ,p_account_definition_code      => p_account_definition_code
           ,p_transaction_coa_id           => p_transaction_coa_id
           ,p_mode                         => p_mode
           ,x_return_status                => l_return_status
           ,x_msg_count                    => l_msg_count
           ,x_msg_data                     => l_msg_data
         );

   --Assign out parameters
   x_msg_count     := l_msg_count;
   x_msg_data      := l_msg_data;
   x_return_status := l_return_status;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tab_pub_pkg.run');

END run;




--Trace initialization
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_tab_pub_pkg;

/
