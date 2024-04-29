--------------------------------------------------------
--  DDL for Package Body XLA_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TAB_PKG" AS
/* $Header: xlatbtab.pkb 120.2 2005/04/28 18:45:45 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_pkg                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder API                                    |
|                                                                       |
| HISTORY                                                               |
|                                                                       |
|    26-JAN-04 A. Quaglia     Created                                   |
|    28-JUL-04 A. Quaglia     Changed message tokens                    |
|                             run:                                      |
|                               added logic to derive token values      |
|                                                                       |
+======================================================================*/

-- Private exceptions

   le_fatal_error                   EXCEPTION;


--Public constants
   C_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   C_RET_STS_ERROR        CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
   C_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
   C_FALSE                CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
   C_TRUE                 CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;


--Private constants
C_API_VERSION          CONSTANT NUMBER        := 1;
C_PACKAGE_NAME         CONSTANT VARCHAR2(30)  := 'XLA_TAB_PKG';

G_COMPILE_STATUS_YES       CONSTANT VARCHAR2(1)   := 'Y';
G_COMPILE_STATUS_NO        CONSTANT VARCHAR2(1)   := 'N';
G_COMPILE_STATUS_RUNNING   CONSTANT VARCHAR2(1)   := 'R';
G_COMPILE_STATUS_ERROR     CONSTANT VARCHAR2(1)   := 'E';

G_DEFAULT_AMB_CONTEXT  CONSTANT VARCHAR2(30)  := 'DEFAULT';


-- Private variables
   g_application_info        xla_cmp_common_pkg.lt_application_info;


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_tab_pkg';

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
         (p_location   => 'xla_tab_pkg.trace');
END trace;



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
l_compile_status_code      VARCHAR2( 1);
l_tad_coa_id               NUMBER;
l_tad_coa_name             VARCHAR2(80);
l_transaction_coa_name     VARCHAR2(80);
l_tad_name                 VARCHAR2(80);
l_amb_context_code         VARCHAR2(30);
l_tad_package_name         VARCHAR2(30);
l_tad_procedure_name       VARCHAR2(30);
l_dynamic_sql              VARCHAR2(5000);
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);

l_return_msg_name          VARCHAR2(30);
l_log_module               VARCHAR2 (2000);
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

   IF NOT FND_API.Compatible_API_Call
      (
        p_current_version_number => C_API_VERSION
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => 'write_online_tab'
       ,p_pkg_name               => C_PACKAGE_NAME
      )
   THEN
      IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
         trace
            ( p_module => l_log_module
             ,p_msg      => 'Incompatible API versions!'
             ,p_level    => C_LEVEL_UNEXPECTED);
         trace
            (p_module => l_log_module
             ,p_msg      => 'Current version: ' || C_API_VERSION
             ,p_level    => C_LEVEL_UNEXPECTED);
         trace
            ( p_module => l_log_module
             ,p_msg      => 'Caller  version: ' || p_api_version
             ,p_level    => C_LEVEL_UNEXPECTED);
      END IF;
      l_return_status   := C_RET_STS_UNEXP_ERROR;
      l_return_msg_name := 'XLA_TAB_INCOMP_API_VERSION';
      RAISE le_fatal_error;
   END IF;

   BEGIN
      --Get the chart of accounts name
      SELECT id_flex_structure_name
        INTO l_transaction_coa_name
        FROM fnd_id_flex_structures_vl ffsvl
       WHERE ffsvl.application_id = 101
         AND ffsvl.id_flex_code   = 'GL#'
         AND ffsvl.id_flex_num    = p_transaction_coa_id;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'The specified Chart Of accounts Id cannot be found.'
            ,p_level    => C_LEVEL_EXCEPTION);
            trace
               ( p_msg      => 'p_transaction_coa_id     : '
                               || p_transaction_coa_id
                ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_status := C_RET_STS_UNEXP_ERROR;

      fnd_message.set_name
            (
              application => 'XLA'
             ,name        => 'XLA_TAB_COA_NOT_FOUND'
            );
      fnd_message.set_token
            (
              token => 'STRUCTURE_ID'
             ,value => p_transaction_coa_id
            );
      fnd_msg_pub.add;
      RAISE le_fatal_error;
   END;

   --Retrieve and set the application info
   IF NOT xla_cmp_common_pkg.get_application_info
                  (
                    p_application_id   => p_application_id
                   ,p_application_info => g_application_info
                  )
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:' ||
                           ' Cannot read application info, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      l_return_status := C_RET_STS_UNEXP_ERROR;
      l_return_msg_name := 'XLA_TAB_CANT_READ_APP_INFO';
      RAISE le_fatal_error;
   END IF;

   --Retrieve the AMB context code
   l_amb_context_code := NVL( fnd_profile.value('XLA_AMB_CONTEXT')
                             ,G_DEFAULT_AMB_CONTEXT
                            );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
      (p_msg      => 'Current AMB context code: ' || l_amb_context_code
      ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   --Retrieve the compilation status of the TAD and the chart of accounts id
   BEGIN
      SELECT compile_status_code
            ,chart_of_accounts_id
            ,name
        INTO l_compile_status_code
            ,l_tad_coa_id
            ,l_tad_name
        FROM xla_tab_acct_defs_vl xtd
       WHERE xtd.application_id               = g_application_info.application_id
         AND xtd.account_definition_code      = p_account_definition_code
         AND xtd.account_definition_type_code = p_account_definition_type_code
         AND xtd.amb_context_code             = l_amb_context_code;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_module => l_log_module
         ,p_msg      => 'TAD Compile status: ' || l_compile_status_code
         ,p_level    => C_LEVEL_STATEMENT);
         trace
         (p_module => l_log_module
         ,p_msg      => 'TAD Chart of Accounts Id: '
                        || l_tad_coa_id
         ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      --If not compiled or compiled in error try to compile it
      IF    l_compile_status_code = G_COMPILE_STATUS_NO
         OR l_compile_status_code = G_COMPILE_STATUS_ERROR
      THEN
         --If compilation failed abort
         IF NOT xla_cmp_tad_pkg.compile_tad_AUTONOMOUS
                           ( p_application_id               => 222
                            ,p_account_definition_code      => p_account_definition_code
                            ,p_account_definition_type_code => p_account_definition_type_code
                            ,p_amb_context_code             => l_amb_context_code
                           )
         THEN
            IF (C_LEVEL_ERROR >= g_log_level) THEN
               trace
               ( p_msg      => 'ERROR:'
                ,p_level    => C_LEVEL_ERROR);
               trace
               ( p_msg      => 'The TAD is not compiled and the '
                               || 'recompilation fails.'
                ,p_level    => C_LEVEL_ERROR);
               trace
               ( p_msg      => 'Please go to the Transaction Account '
                               || 'Definition Setup page and recompile it' ||
                               ' manually'
                ,p_level    => C_LEVEL_ERROR);
               trace
               ( p_msg      => 'p_account_definition_code     : '
                               || p_account_definition_code
                ,p_level    => C_LEVEL_ERROR);
               trace
               ( p_msg      => 'p_account_definition_type_code: '
                               || p_account_definition_type_code
                ,p_level    => C_LEVEL_ERROR);
               trace
               ( p_msg      => 'amb_context_code              : '
                               || l_amb_context_code
                ,p_level    => C_LEVEL_ERROR);
            END IF;
            l_return_msg_name := 'XLA_TAB_CANT_COMPILE_TAD';
            l_return_status := C_RET_STS_ERROR;
            RAISE le_fatal_error;
         END IF;
      --
      ELSIF l_compile_status_code = G_COMPILE_STATUS_RUNNING
      THEN
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
               ( p_msg      => 'ERROR:'
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'The TAD is being recompiled. Try again later.'
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'p_account_definition_code     : '
                               || p_account_definition_code
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'p_account_definition_type_code: '
                               || p_account_definition_type_code
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'amb_context_code              : '
                               || l_amb_context_code
                ,p_level    => C_LEVEL_ERROR);
         END IF;
         l_return_msg_name := 'XLA_TAB_TAD_COMP_RUNNING';
         l_return_status := C_RET_STS_ERROR;
         RAISE le_fatal_error;
      END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'The specified TAD cannot be found '
                           || 'in the table xla_tab_acct_defs_b:'
            ,p_level    => C_LEVEL_EXCEPTION);
            trace
               ( p_msg      => 'p_account_definition_code     : '
                               || p_account_definition_code
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'p_account_definition_type_code: '
                               || p_account_definition_type_code
                ,p_level    => C_LEVEL_ERROR);
            trace
               ( p_msg      => 'amb_context_code              : '
                               || l_amb_context_code
                ,p_level    => C_LEVEL_ERROR);
      END IF;
      l_return_status := C_RET_STS_UNEXP_ERROR;

      DECLARE
         l_amb_context_meaning VARCHAR2(80);
         l_owner_meaning       VARCHAR2(80);
      BEGIN
         --Try to get the meaning of the amb context code
         BEGIN
            l_amb_context_meaning := xla_lookups_pkg.get_meaning
            (
               p_lookup_type   => 'XLA_AMB_CONTEXT_TYPE'
              ,p_lookup_code   => l_amb_context_code
            );
         EXCEPTION
         --If not possible use the amb context code
         WHEN OTHERS
         THEN
            l_amb_context_meaning := l_amb_context_code;
         END;
         --Try to get the meaning of the owner
         BEGIN

            l_owner_meaning := xla_lookups_pkg.get_meaning
            (
               p_lookup_type   => 'XLA_OWNER_TYPE'
              ,p_lookup_code   => p_account_definition_type_code
            );
         EXCEPTION
         --If not possible use the the type_code
         WHEN OTHERS
         THEN
            l_owner_meaning := p_account_definition_type_code;
         END;

         fnd_message.set_name
            (
              application => 'XLA'
             ,name        => 'XLA_TAB_CANT_FIND_TAD'
            );
         fnd_message.set_token
            (
              token => 'AMB_CONTEXT'
             ,value => l_amb_context_meaning
            );
         fnd_message.set_token
            (
              token => 'OWNER'
             ,value => l_owner_meaning
            );
         fnd_message.set_token
            (
              token => 'TRX_ACCT_DEF_CODE'
             ,value => p_account_definition_code
            );
         fnd_msg_pub.add;

         RAISE le_fatal_error;
      END;
   END;

   --If the TAD chart of accounts id is not null
   --and it does not match p_transaction_coa_id
   IF l_tad_coa_id IS NOT NULL
   AND l_tad_coa_id <> p_transaction_coa_id
   THEN
   BEGIN
      --Get the tad chart of accounts name
      SELECT id_flex_structure_name
        INTO l_tad_coa_name
        FROM fnd_id_flex_structures_vl ffsvl
       WHERE ffsvl.application_id = 101
         AND ffsvl.id_flex_code   = 'GL#'
         AND ffsvl.id_flex_num    = l_tad_coa_id;


      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'TAD coa id  and p_transaction_coa_id cannot differ'
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'l_tad_coa_id = '  || l_tad_coa_id
            ,p_level    => C_LEVEL_EXCEPTION);
         trace
            (p_msg      => 'p_transaction_coa_id = '  || p_transaction_coa_id
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;

      fnd_message.set_name
            (
              application => 'XLA'
             ,name        => 'XLA_TAB_TAD_COA_DIFF_TRANS_COA'
            );
      fnd_message.set_token
            (
              token => 'TRX_ACCT_DEF'
             ,value => l_tad_name
            );
      fnd_message.set_token
            (
              token => 'STRUCTURE_NAME'
             ,value => l_tad_coa_name
            );
      fnd_msg_pub.add;
      RAISE le_fatal_error;
   END;

   END IF;

   --Build the package name
   IF NOT xla_cmp_tad_pkg.get_tad_package_name
                   (
                      p_application_id               => p_application_id
                     ,p_account_definition_code      => p_account_definition_code
                     ,p_account_definition_type_code => p_account_definition_type_code
                     ,p_amb_context_code             => l_amb_context_code
                     ,p_tad_package_name             => l_tad_package_name
                   )
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:' ||
                           'get_tad_package_name failed'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      x_return_status := C_RET_STS_UNEXP_ERROR;
      RAISE le_fatal_error;
   END IF;

   IF p_mode = 'ONLINE'
   THEN
      l_tad_procedure_name := 'trans_account_def_online';
   ELSIF p_mode = 'BATCH'
   THEN
      l_tad_procedure_name := 'trans_account_def_batch';
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:' ||
                           'Invalid p_mode:' || p_mode
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      --Set the message on the stack
      fnd_message.set_name
            (
              application => 'XLA'
             ,name        => 'XLA_TAB_INVALID_MODE'
            );
      fnd_message.set_token
            (
              token => 'FUNCTION_NAME'
             ,value => 'XLA_TAB_PKG.run'
            );
      fnd_message.set_token
            (
              token => 'MODE'
             ,value => NVL(p_mode, '(NULL)')
            );
      --Add the message to the stack
      fnd_msg_pub.add;
      --Raise a local exception
      RAISE le_fatal_error;
   END IF;

   l_dynamic_sql :=
   'BEGIN ' || l_tad_package_name || '.' || l_tad_procedure_name
   || '
    (
      p_transaction_coa_id => :1
     ,p_accounting_coa_id  => :2
     ,x_return_status      => :3
     ,x_msg_count          => :4
     ,x_msg_data           => :5
    );
    END;
    ';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
      (p_msg      => 'Dynamic sql'
      ,p_level    => C_LEVEL_STATEMENT);

      xla_cmp_common_pkg.dump_text
                    (
                      p_text          => l_dynamic_sql
                    );
   END IF;

   --execute the dynamic SQL in an anonymous block
   BEGIN
      EXECUTE IMMEDIATE l_dynamic_sql
      USING IN p_transaction_coa_id
           ,IN p_transaction_coa_id
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data;

      EXCEPTION
      WHEN OTHERS
      THEN

         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'EXCEPTION:' ||
                              'The TAD procedure '
               ,p_level    => C_LEVEL_EXCEPTION);
            trace
               (p_msg      => 'EXCEPTION:' ||
                              l_tad_package_name || '.' || l_tad_procedure_name
               ,p_level    => C_LEVEL_EXCEPTION);
            trace
               (p_msg      => 'EXCEPTION:' ||
                              'could not be invoked because of the following '
               ,p_level    => C_LEVEL_EXCEPTION);
            trace
               (p_msg      => 'EXCEPTION:' ||
                              'database error: '
               ,p_level    => C_LEVEL_EXCEPTION);
            trace
               (p_msg      => 'Error message: '|| SQLERRM
               ,p_level    => C_LEVEL_EXCEPTION);
         END IF;
         fnd_message.set_name
         (
           application => 'XLA'
          ,name        => 'XLA_TAB_CANT_INVOKE_TAD_PROC'
         );
         fnd_message.set_token
         (
           token => 'PROCEDURE'
          ,value => l_tad_package_name || '.' || l_tad_procedure_name
         );
         fnd_message.set_token
         (
           token => 'ERROR'
          ,value => SQLERRM
         );
         fnd_msg_pub.add;

         RAISE le_fatal_error;
   END;

   --Assign out parameters
   x_msg_count     := NVL(l_msg_count, 0); --NVL for java callers
   x_msg_data      := l_msg_data;
   x_return_status := l_return_status;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN le_fatal_error
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'EXCEPTION:' ||
                           ' Fatal error, aborting...'
            ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   IF l_return_status IS NULL
   THEN
      l_return_status := C_RET_STS_UNEXP_ERROR;
   END IF;
   IF l_return_msg_name IS NOT NULL
   THEN
      --There is a detailed message to push
      fnd_message.set_name
      (
        application => 'XLA'
       ,name        => l_return_msg_name
      );
      fnd_msg_pub.add;
   END IF;
   fnd_msg_pub.Count_And_Get
      (
        p_count => l_msg_count
       ,p_data  => l_msg_data
      );
   --for Forms callers
   fnd_message.set_encoded
      (
        encoded_message => l_msg_data
      );
   --Assign out parameters
   x_msg_count     := NVL(l_msg_count, 0); --NVL for java callers
   x_msg_data      := l_msg_data;
   x_return_status := l_return_status;

WHEN xla_exceptions_pkg.application_exception
THEN
   RAISE;
WHEN OTHERS
THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_tab_pkg.run');

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

END xla_tab_pkg;

/
