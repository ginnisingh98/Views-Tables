--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_ERRORS_PKG" as
/* $Header: xlaaerrs.pkb 120.1.12010000.2 2009/08/13 16:23:10 vkasina noship $
 * */
/*======================================================================+
 * |             Copyright (c) 2001-2002 Oracle Corporation                |
 * |                       Redwood Shores, CA, USA                         |
 * |                         All rights reserved.                          |
 * +=======================================================================+
 * | PACKAGE NAME                                                          |
 * |    xla_accounting_errors_pkg                                          |
 * |                                                                       |
 * | DESCRIPTION                                                           |
 * |    Enhanced error messages                                            |
 * |                                                                       |
 * | HISTORY                                                               |
 * |    08/12/2009   Vamsi Kasina   Created                                |
 * |                                                                       |
 * +======================================================================*/


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_errors_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
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
         (p_location   => 'xla_accounting_errors_pkg.trace');
END trace;

PROCEDURE msg_bflow_pe_not_found
       (p_application_id          IN  NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL) IS

     l_check                      BOOLEAN;
     l_trx_data                   VARCHAR2(2000);
     l_log_module                VARCHAR2(240);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.msg_bflow_pe_not_found';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure msg_bflow_pe_not_found'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

     l_check := FALSE;

     IF p_value_2 IS NOT NULL THEN

       l_trx_data := xla_datafixes_pub.get_transaction_details(p_application_id,p_value_2,'Y',p_value_3);

       IF l_trx_data IS NOT NULL THEN
          l_check := TRUE;
          xla_accounting_err_pkg.build_message
                    (p_appli_s_name  => 'XLA'
                    ,p_msg_name      => 'XLA_AP_BFLOW_PE_NOT_FOUND_DTL'
                    ,p_token_1       => 'APPLICATION_NAME'
                    ,p_value_1       => p_value_1
                    ,p_token_2       => 'TRX_DATA'
                    ,p_value_2       => l_trx_data
                    ,p_entity_id     => p_entity_id
                    ,p_event_id      => p_event_id
                    ,p_ledger_id     => p_ledger_id);
       END IF;
     END IF;

     IF NOT l_check THEN

       xla_accounting_err_pkg.build_message
                    (p_appli_s_name  => 'XLA'
                    ,p_msg_name      => 'XLA_AP_BFLOW_PE_NOT_FOUND'
                    ,p_token_1       => 'APPLICATION_NAME'
                    ,p_value_1       => p_value_1
                    ,p_entity_id     => p_entity_id
                    ,p_event_id      => p_event_id
                    ,p_ledger_id     => p_ledger_id);

     END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure msg_bflow_pe_not_found'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
          (p_location       => 'xla_accounting_errors_pkg.msg_bflow_pe_not_found');

END msg_bflow_pe_not_found;

PROCEDURE ap_modify_message
       (p_application_id          IN NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL
       ,p_ae_header_id            IN  NUMBER   DEFAULT NULL
       ,p_ae_line_num             IN  NUMBER   DEFAULT NULL
       ,p_accounting_batch_id     IN  NUMBER   DEFAULT NULL) IS

BEGIN
    null;

END ap_modify_message;

PROCEDURE ar_modify_message
       (p_application_id          IN NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL
       ,p_ae_header_id            IN  NUMBER   DEFAULT NULL
       ,p_ae_line_num             IN  NUMBER   DEFAULT NULL
       ,p_accounting_batch_id     IN  NUMBER   DEFAULT NULL) IS

BEGIN
    null;

END ar_modify_message;


PROCEDURE common_modify_message
       (p_application_id          IN NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL
       ,p_ae_header_id            IN  NUMBER   DEFAULT NULL
       ,p_ae_line_num             IN  NUMBER   DEFAULT NULL
       ,p_accounting_batch_id     IN  NUMBER   DEFAULT NULL) IS

  l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.common_modify_message';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure common_modify_message'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF p_msg_name = 'XLA_AP_BFLOW_PE_NOT_FOUND' THEN

      msg_bflow_pe_not_found (p_application_id => p_application_id
                             ,p_appli_s_name   => p_appli_s_name
                             ,p_msg_name       => p_msg_name
                             ,p_token_1        => p_token_1
                             ,p_value_1        => p_value_1
                             ,p_token_2        => p_token_2
                             ,p_value_2        => p_value_2
                             ,p_token_3        => p_token_3
                             ,p_value_3        => p_value_3
                             ,p_entity_id      => p_entity_id
                             ,p_event_id       => p_event_id
                             ,p_ledger_id      => p_ledger_id);

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure common_modify_message'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
          (p_location       => 'xla_accounting_errors_pkg.common_modify_message');

END common_modify_message;

PROCEDURE modify_message
       (p_application_id          IN NUMBER
       ,p_appli_s_name            IN  VARCHAR2
       ,p_msg_name                IN  VARCHAR2
       ,p_token_1                 IN  VARCHAR2
       ,p_value_1                 IN  VARCHAR2
       ,p_token_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_2                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_3                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_4                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_5                 IN  VARCHAR2 DEFAULT NULL
       ,p_token_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_value_6                 IN  VARCHAR2 DEFAULT NULL
       ,p_entity_id               IN  NUMBER
       ,p_event_id                IN  NUMBER
       ,p_ledger_id               IN  NUMBER   DEFAULT NULL
       ,p_ae_header_id            IN  NUMBER   DEFAULT NULL
       ,p_ae_line_num             IN  NUMBER   DEFAULT NULL
       ,p_accounting_batch_id     IN  NUMBER   DEFAULT NULL) IS

  l_log_module                VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.modify_message';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure modify_message'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '|| p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_appli_s_name = '||p_appli_s_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_msg_name = '||p_msg_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_1 = '||p_token_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_1 = '||p_value_1
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_2 = '||p_token_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_2 = '||p_value_2
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_3 = '||p_token_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_3 = '||p_value_3
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_4 = '||p_token_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_4 = '||p_value_4
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_5 = '||p_token_5
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_5 = '||p_value_5
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_6 = '||p_token_6
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_6 = '||p_value_6
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_id = '||p_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ae_header_id = '||p_ae_header_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ae_line_num = '||p_ae_line_num
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_batch_id = '||p_accounting_batch_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF p_msg_name IN ('XLA_AP_BFLOW_PE_NOT_FOUND') THEN
      common_modify_message(p_application_id        => p_application_id
                           ,p_appli_s_name          => p_appli_s_name
                           ,p_msg_name              => p_msg_name
                           ,p_token_1               => p_token_1
                           ,p_value_1               => p_value_1
                           ,p_token_2               => p_token_2
                           ,p_value_2               => p_value_2
                           ,p_token_3               => p_token_3
                           ,p_value_3               => p_value_3
                           ,p_token_4               => p_token_4
                           ,p_value_4               => p_value_4
                           ,p_token_5               => p_token_5
                           ,p_value_5               => p_value_5
                           ,p_token_6               => p_token_6
                           ,p_value_6               => p_value_6
                           ,p_entity_id             => p_entity_id
                           ,p_event_id              => p_event_id
                           ,p_ledger_id             => p_ledger_id
                           ,p_ae_header_id          => p_ae_header_id
                           ,p_ae_line_num           => p_ae_line_num
                           ,p_accounting_batch_id   => p_accounting_batch_id);

   ELSE
      IF p_application_id = 200 THEN
         ap_modify_message(p_application_id        => p_application_id
                          ,p_appli_s_name          => p_appli_s_name
                          ,p_msg_name              => p_msg_name
                          ,p_token_1               => p_token_1
                          ,p_value_1               => p_value_1
                          ,p_token_2               => p_token_2
                          ,p_value_2               => p_value_2
                          ,p_token_3               => p_token_3
                          ,p_value_3               => p_value_3
                          ,p_token_4               => p_token_4
                          ,p_value_4               => p_value_4
                          ,p_token_5               => p_token_5
                          ,p_value_5               => p_value_5
                          ,p_token_6               => p_token_6
                          ,p_value_6               => p_value_6
                          ,p_entity_id             => p_entity_id
                          ,p_event_id              => p_event_id
                          ,p_ledger_id             => p_ledger_id
                          ,p_ae_header_id          => p_ae_header_id
                          ,p_ae_line_num           => p_ae_line_num
                          ,p_accounting_batch_id   => p_accounting_batch_id);

      ELSIF p_application_id = 222 THEN
         ar_modify_message(p_application_id        => p_application_id
                          ,p_appli_s_name          => p_appli_s_name
                          ,p_msg_name              => p_msg_name
                          ,p_token_1               => p_token_1
                          ,p_value_1               => p_value_1
                          ,p_token_2               => p_token_2
                          ,p_value_2               => p_value_2
                          ,p_token_3               => p_token_3
                          ,p_value_3               => p_value_3
                          ,p_token_4               => p_token_4
                          ,p_value_4               => p_value_4
                          ,p_token_5               => p_token_5
                          ,p_value_5               => p_value_5
                          ,p_token_6               => p_token_6
                          ,p_value_6               => p_value_6
                          ,p_entity_id             => p_entity_id
                          ,p_event_id              => p_event_id
                          ,p_ledger_id             => p_ledger_id
                          ,p_ae_header_id          => p_ae_header_id
                          ,p_ae_line_num           => p_ae_line_num
                          ,p_accounting_batch_id   => p_accounting_batch_id);
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure modify_message'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
 WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
 WHEN OTHERS THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'p_appli_s_name = '||p_appli_s_name
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_msg_name = '||p_msg_name
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_1 = '||p_token_1
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_1 = '||p_value_1
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_2 = '||p_token_2
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_2 = '||p_value_2
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_3 = '||p_token_3
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_3 = '||p_value_3
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_4 = '||p_token_4
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_4 = '||p_value_4
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_5 = '||p_token_5
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_5 = '||p_value_5
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_token_6 = '||p_token_6
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_value_6 = '||p_value_6
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_id = '||p_entity_id
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ledger_id = '||p_ledger_id
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ae_header_id = '||p_ae_header_id
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ae_line_num = '||p_ae_line_num
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_batch_id = '||p_accounting_batch_id
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;

   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_errors_pkg.modify_message');

END modify_message;

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

end xla_accounting_errors_pkg;

/
