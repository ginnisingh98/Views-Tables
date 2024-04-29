--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_PUB_PKG" AS
-- $Header: xlaappub.pkb 120.24.12010000.5 2009/04/15 14:11:02 nksurana ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_pub_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This package contains all the public APIs related to Accounting        |
|     Program. It has two APIs, one to account for a "batch of docuements"   |
|     and one to account for a single "docuemnt".                            |
|     All these APIs are wrapper over routines in the "xla_accounting_pkg".  |
|                                                                            |
| HISTORY                                                                    |
|     11/08/2002    S. Singhania      Created                                |
|     07/22/2003    S. Singhania      Added NOCOPY hint to the OUT parameters|
|     08/05/2003    S. Singhania      Added P_ENTITY_ID and P_ACCOUNTING_FLAG|
|                                       to ACCOUNTING_PROGRAM_DOCUMENT       |
|                                     Modified ACCOUNTING_PROGRAM_DOCUMENT   |
|     09/22/2003    S. Singhania      Added p_source_application to the API  |
|                                       ACCOUNTING_PROGRAM_BATCH             |
|     10/14/2003    S. Singhania      Added semicolon to the EXIT statement. |
|                                       (Bug # 3165900)                      |
|     12/02/2003    S. Singhania      Modified the submit_request call in    |
|                                       ACCOUNTING_PROGRAM_DOCUMENT to match |
|                                       the correct parameter order in prog  |
|                                       XLAACCPB. (Bug # 3290398)            |
|     02/28/2004    S. Singhania      Bug 3416534. Added local trace package |
|                                       and FND_LOG messages.                |
|     03/23/2004    S. Singhania      Added a parameter p_module to the TRACE|
|                                       calls and the procedure.             |
|     04/25/2005    S. Singhania      Bug 4323078. Temporarily modified body |
|                                       of accounting_progra_document to pass|
|                                       NULL for valuation method while      |
|                                       calling xla_events_pkg.get_entity_id |
|     04/27/2005    V. Kumar          Bug 4323078. Removed the temporary fix |
|                                       and overloaded the procedure         |
|                                       get_accounting_document with extra   |
|                                       valuation method parameter.          |
|     04/29/2005    S. Singhania      Bug 4332679. Modified trace procedure  |
|                                       for the GSCC check File.Sql.46       |
|     08/01/2005    W. Chan           4458381 - Public Sector Enhancement    |
|     03/07/2006    V. Swapna         Bug 5080849. Modified submit request   |
|                                       call in accounting_program_document. |
|     03/21/2006    A. Wan            5109240a - accounting_program_events   |
|                                       should validate the accounting mode  |
|                                       in full (ie DRAFT, FINAL).           |
|     31/12/2007    V. Swapna         5339999 - Historic upgrade of sec/alc  |
|                                     Don't allow online accounting to run   |
|                                     when the upgrade process is running.   |
+===========================================================================*/

C_NUM                 CONSTANT NUMBER       := 9.99E125;
C_CHAR                CONSTANT VARCHAR2(1)  := '
';

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_pub_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
         (p_location   => 'xla_accounting_pub_pkg.trace');
END trace;

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_batch
       (p_source_application_id      IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_ledger_id                  IN  NUMBER
       ,p_process_category           IN  VARCHAR2
       ,p_end_date                   IN  DATE
       ,p_accounting_flag            IN  VARCHAR2
       ,p_accounting_mode            IN  VARCHAR2
       ,p_error_only_flag            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_gl_batch_name              IN  VARCHAR2
       ,p_valuation_method           IN  VARCHAR2
       ,p_security_id_int_1          IN  NUMBER
       ,p_security_id_int_2          IN  NUMBER
       ,p_security_id_int_3          IN  NUMBER
       ,p_security_id_char_1         IN  VARCHAR2
       ,p_security_id_char_2         IN  VARCHAR2
       ,p_security_id_char_3         IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER) IS
l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_batch';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   xla_accounting_pkg.accounting_program_batch
      (p_source_application_id           => p_source_application_id
      ,p_application_id                  => p_application_id
      ,p_ledger_id                       => p_ledger_id
      ,p_process_category                => p_process_category
      ,p_end_date                        => p_end_date
      ,p_accounting_flag                 => p_accounting_flag
      ,p_accounting_mode                 => p_accounting_mode
      ,p_error_only_flag                 => p_error_only_flag
      ,p_transfer_flag                   => p_transfer_flag
      ,p_gl_posting_flag                 => p_gl_posting_flag
      ,p_gl_batch_name                   => p_gl_batch_name
      ,p_valuation_method                => p_valuation_method
      ,p_security_id_int_1               => p_security_id_int_1
      ,p_security_id_int_2               => p_security_id_int_2
      ,p_security_id_int_3               => p_security_id_int_3
      ,p_security_id_char_1              => p_security_id_char_1
      ,p_security_id_char_2              => p_security_id_char_2
      ,p_security_id_char_3              => p_security_id_char_3
      ,p_accounting_batch_id             => p_accounting_batch_id
      ,p_errbuf                          => p_errbuf
      ,p_retcode                         => p_retcode);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_BATCH'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_accounting_pub_pkg.accounting_program_batch');
END accounting_program_batch; -- end of procedure


--============================================================================
--
-- Overloaded with extra valuation_method parameter
--
--============================================================================
PROCEDURE accounting_program_document
       (p_event_source_info          IN  xla_events_pub_pkg.t_event_source_info
       ,p_application_id             IN  NUMBER      DEFAULT NULL
       ,p_valuation_method           IN  VARCHAR2
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_request_id                 OUT NOCOPY NUMBER) IS
l_entity_id                 NUMBER;
l_application_id            NUMBER;
l_ledger_id                 NUMBER;
l_log_module                VARCHAR2(240);
historic_upgrade_running    EXCEPTION;
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_document';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure ACCOUNTING_PROGRAM_DOCUMENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_id = '||p_entity_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_valuation_method = '||p_valuation_method
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;


   -- commented code added in 7253269 to test fix for 7380459 gl post error
   --XLA_ACCOUNTING_CACHE_PKG.g_reversal_error := FALSE;


   ----------------------------------------------------------------------------
   -- Fetch entity information for the transaction.
   ----------------------------------------------------------------------------
   IF p_entity_id IS NULL THEN
      -------------------------------------------------------------------------
      -- Following sets the Security Context for the execution. This enables
      -- the accounting program to respect the transaction security.
      -------------------------------------------------------------------------

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Setting security context for the applciation '||
                           p_event_source_info.application_id
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      xla_security_pkg.set_security_context(p_event_source_info.application_id);

      l_entity_id := xla_events_pkg.get_entity_id
                        (p_event_source_info     => p_event_source_info
                        ,p_valuation_method      => p_valuation_method );
      l_application_id := p_event_source_info.application_id;
      l_ledger_id      := p_event_source_info.ledger_id;
   ELSE
      -- If application ID is not specified then derive entity information.
      -- using just the entity_id. If the application ID is provided then
      -- derive the application ID based enitity_id/application ID for
      -- performance reasons.

      IF p_application_id IS NULL THEN
         SELECT APPLICATION_ID
               ,LEDGER_ID
               ,ENTITY_ID
         INTO L_APPLICATION_ID
             ,L_LEDGER_ID
             ,L_ENTITY_ID
         FROM XLA_TRANSACTION_ENTITIES
         WHERE ENTITY_ID = P_ENTITY_ID;
      ELSE
         SELECT APPLICATION_ID
               ,LEDGER_ID
               ,ENTITY_ID
         INTO L_APPLICATION_ID
             ,L_LEDGER_ID
             ,L_ENTITY_ID
         FROM XLA_TRANSACTION_ENTITIES
         WHERE ENTITY_ID = P_ENTITY_ID
         AND   application_id = p_application_id;
      END IF;

      -- Added for bug 4599776
      xla_security_pkg.set_security_context(l_application_id);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_application_id = '||l_application_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_ledger_id = '||l_ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_entity_id = '||l_entity_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_offline_flag = '||p_offline_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF NOT is_historic_upgrade_running(l_ledger_id) THEN -- Historic upgrade

   IF p_offline_flag = 'N' THEN

      -- added code to test fix for 7380459 gl post error
      XLA_ACCOUNTING_CACHE_PKG.g_reversal_error := FALSE;


      xla_accounting_pkg.accounting_program_document
         (p_application_id                  => l_application_id
         ,p_entity_id                       => l_entity_id
         ,p_accounting_flag                 => p_accounting_flag
         ,p_accounting_mode                 => p_accounting_mode
         ,p_gl_posting_flag                 => p_gl_posting_flag
         ,p_offline_flag                    => p_offline_flag
         ,p_accounting_batch_id             => p_accounting_batch_id
         ,p_errbuf                          => p_errbuf
         ,p_retcode                         => p_retcode);


   ELSE
      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Calling procedure FND_REQUEST.SUBMIT_REQUEST'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      p_request_id :=

  fnd_request.submit_request
            (application     => 'XLA'
            ,program         => 'XLAACCPB'
            ,description     => NULL
            ,start_time      => NULL
            ,sub_request     => FALSE
            ,argument1       => l_application_id  -- application_id
            ,argument2       => NULL              -- source_application_id
            ,argument3       => NULL              -- dummy
            ,argument4       => l_ledger_id       -- ledger_id
            ,argument5       => NULL              -- process_category_code
            ,argument6       => NULL              -- end_date
            ,argument7       => p_accounting_flag -- create_accounting_flag
            ,argument8       => NULL              -- dummy_param_1
            ,argument9       => p_accounting_mode -- accounting_mode
            ,argument10      => NULL              -- dummy_param_2
            ,argument11      => 'N'               -- errors_only_flag
            ,argument12      => 'D'               -- report_style
            ,argument13      => p_transfer_flag   -- transfer_to_gl_flag
            ,argument14      => NULL              -- dummy_param_3
            ,argument15      => p_gl_posting_flag -- post_in_gl_flag
            ,argument16      => NULL              -- gl_batch_name
            ,argument17      => fnd_profile.value('CURRENCY:MIXED_PRECISION') -- min_precision
            ,argument18      => NULL              -- include_zero_amount_lines
            ,argument19      => NULL              -- request_id
            ,argument20      => l_entity_id       -- entity_id
            ,argument21      => NULL              -- source_application_name
            ,argument22      => NULL              -- application_name
            ,argument23      => NULL              -- ledger_name
            ,argument24      => NULL              -- process_category_name
            ,argument25      => NULL              -- create_accounting
            ,argument26      => NULL              -- accounting_mode_name
            ,argument27      => NULL              -- errors_only
            ,argument28      => NULL              -- accounting_report_level
            ,argument29      => NULL              -- transfer_to_gl
            ,argument30      => NULL              -- post_in_gl
            ,argument31      => NULL              -- include_zero_amt_lines
            ,argument32      => p_valuation_method-- valuation_method_code
            ,argument33      => NULL              -- security_int_1
            ,argument34      => NULL              -- security_int_2
            ,argument35      => NULL              -- security_int_3
            ,argument36      => NULL              -- security_char_1
            ,argument37      => NULL              -- security_char_2
            ,argument38      => NULL    );        -- security_char_3

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
            (p_msg      => 'Procedure FND_REQUEST.SUBMIT_REQUEST executed'
            ,p_level    => C_LEVEL_EVENT
            ,p_module   => l_log_module);
      END IF;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'p_request_id = '||p_request_id
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      IF p_request_id = 0 THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'Technical Error : Unable to submit the request'
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_TECHNICAL_ERROR'
            ,p_token_1        => 'APPLICATION_NAME'
            ,p_value_1        => 'SLA');
      END IF;

   END IF;
   ELSE
      raise historic_upgrade_running;
   END IF;

   IF XLA_ACCOUNTING_CACHE_PKG.g_hist_bflow_error_exists THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Missing bflow entries due to historic upgrade.'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;
     p_retcode := 2;

   END IF;

     -- bug 7253269, Online case

    IF XLA_ACCOUNTING_CACHE_PKG.g_reversal_error THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'Could not create reversal entry'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;
     p_retcode := 2;

   END IF;




   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure ACCOUNTING_PROGRAM_DOCUMENT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN historic_upgrade_running THEN
 p_retCode := 2;
 p_errBuf  := 'XLA_UPG_HIST_RUNNING';


WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location   => 'xla_accounting_pub_pkg.accounting_program_document');
END accounting_program_document; -- end of procedure


--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_document
       (p_event_source_info          IN  xla_events_pub_pkg.t_event_source_info
       ,p_application_id             IN  NUMBER      DEFAULT NULL
       ,p_entity_id                  IN  NUMBER
       ,p_accounting_flag            IN  VARCHAR2    DEFAULT 'Y'
       ,p_accounting_mode            IN  VARCHAR2
       ,p_transfer_flag              IN  VARCHAR2
       ,p_gl_posting_flag            IN  VARCHAR2
       ,p_offline_flag               IN  VARCHAR2
       ,p_accounting_batch_id        OUT NOCOPY NUMBER
       ,p_errbuf                     OUT NOCOPY VARCHAR2
       ,p_retcode                    OUT NOCOPY NUMBER
       ,p_request_id                 OUT NOCOPY NUMBER) IS
BEGIN
   accounting_program_document
      ( p_event_source_info    =>  p_event_source_info
       ,p_application_id       =>  p_application_id
       ,p_valuation_method     =>  NULL                 -- pass NULL for valuation method
       ,p_entity_id            =>  p_entity_id
       ,p_accounting_flag      =>  p_accounting_flag
       ,p_accounting_mode      =>  p_accounting_mode
       ,p_transfer_flag        =>  p_transfer_flag
       ,p_gl_posting_flag      =>  p_gl_posting_flag
       ,p_offline_flag         =>  p_offline_flag
       ,p_accounting_batch_id  =>  p_accounting_batch_id
       ,p_errbuf               =>  p_errbuf
       ,p_retcode              =>  p_retcode
       ,p_request_id           =>  p_request_id );

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_accounting_pub_pkg.accounting_program_document');
END accounting_program_document; -- end of procedure

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_doc_batch
(p_application_id        IN INTEGER
,p_accounting_mode       IN VARCHAR2
,p_gl_posting_flag       IN VARCHAR2
,p_accounting_batch_id   IN OUT NOCOPY INTEGER
,p_errbuf                IN OUT NOCOPY VARCHAR2
,p_retcode               IN OUT NOCOPY INTEGER)
IS
l_count                  INTEGER;
l_log_module             VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_doc_batch';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure accounting_program_doc_batch'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   UPDATE xla_acct_prog_docs_gt xap
      SET entity_id =
          (SELECT xte.entity_id
             FROM xla_transaction_entities xte
            WHERE xte.application_id                  = p_application_id
              AND xte.ledger_id                       = xap.ledger_id
              AND xte.entity_code                     = xap.entity_type_code
              AND NVL(xte.valuation_method,C_CHAR)    = NVL(xap.valuation_method,C_CHAR)
              AND NVL(xte.source_id_int_1,C_NUM)      = NVL(xap.source_id_int_1,C_NUM)
              AND NVL(xte.source_id_int_2,C_NUM)      = NVL(xap.source_id_int_2,C_NUM)
              AND NVL(xte.source_id_int_3,C_NUM)      = NVL(xap.source_id_int_3,C_NUM)
              AND NVL(xte.source_id_int_4,C_NUM)      = NVL(xap.source_id_int_4,C_NUM)
              AND NVL(xte.source_id_char_1,C_CHAR)    = NVL(xap.source_id_char_1,C_CHAR)
              AND NVL(xte.source_id_char_2,C_CHAR)    = NVL(xap.source_id_char_2,C_CHAR)
              AND NVL(xte.source_id_char_3,C_CHAR)    = NVL(xap.source_id_char_3,C_CHAR)
              AND NVL(xte.source_id_char_4,C_CHAR)    = NVL(xap.source_id_char_4,C_CHAR))
    WHERE xap.entity_id IS NULL;

   SELECT count(*) INTO l_count
     FROM xla_acct_prog_docs_gt xap
    WHERE entity_id IS NULL
       OR NOT EXISTS (SELECT entity_id
                        FROM xla_transaction_entities xte
                       WHERE xte.application_id = p_application_id
                         AND xte.entity_id      = xap.entity_id);

   IF (l_count > 0) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace
             (p_msg      => 'Invalid entity is used in the xla_acct_prog_docs_gt'
             ,p_level    => C_LEVEL_ERROR
             ,p_module   =>l_log_module);
      END IF;
      xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_COMMON_ERROR'
            ,p_token_1        => 'ERROR'
            ,p_value_1        => 'Invalid entity is used in the xla_acct_prog_docs_gt'
            ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_pub_pkg.accounting_program_doc_batch');

   END IF;

   INSERT INTO XLA_ACCT_PROG_EVENTS_GT(event_id, ledger_id)
     SELECT xe.event_id, xte.ledger_id
       FROM xla_acct_prog_docs_gt           xap
           ,xla_events                      xe
           ,xla_transaction_entities        xte
      WHERE xte.application_id              = p_application_id
        AND xte.entity_id                   = xap.entity_id
        AND xap.entity_id                   IS NOT NULL
        AND xe.application_id               = xte.application_id
        AND xe.entity_id                    = xte.entity_id
        AND NVL(budgetary_control_flag,'N') = DECODE(p_accounting_mode
                                                    ,'D','N'
                                                    ,'F','N'
                                                    ,'Y');

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# row inserted into xla_acct_prog_events_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;


   --7390659 change start

    INSERT INTO xla_evt_class_orders_gt
      (event_class_code
      ,processing_order
      )
      SELECT xec.event_class_code
           , NVL(t.max_level, -1)
        FROM xla_event_classes_b xec
           , (SELECT application_id, event_class_code, max(LEVEL) AS max_level
                FROM (SELECT application_id, event_class_code, prior_event_class_code
                        FROM xla_event_class_predecs
                       WHERE application_id = p_application_id
                       UNION
                      SELECT application_id, prior_event_class_code, NULL
                        FROM xla_event_class_predecs
                       WHERE application_id = p_application_id) xep
                CONNECT BY application_id         = PRIOR application_id
                       AND prior_event_class_code = PRIOR event_class_code
                 GROUP BY application_id, event_class_code) t
       WHERE xec.event_class_code = t.event_class_code(+)
         AND xec.application_id   = t.application_id(+)
         AND xec.application_id   = p_application_id
         AND xec.event_class_code <> 'MANUAL';


    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of rows inserted into xla_evt_class_orders_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;


--7390659 change end





   xla_accounting_pkg.accounting_program_events
           (p_application_id      => p_application_id
           ,p_accounting_mode     => p_accounting_mode
           ,p_gl_posting_flag     => p_gl_posting_flag
           ,p_offline_flag        => 'N'
           ,p_accounting_batch_id => p_accounting_batch_id
           ,p_errbuf              => p_errbuf
           ,p_retcode             => p_retcode);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure accounting_program_doc_batch'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_accounting_pub_pkg.accounting_program_doc_batch');
END accounting_program_doc_batch; -- end of procedure

--============================================================================
--
--
--
--============================================================================
PROCEDURE accounting_program_events
(p_application_id        IN INTEGER
,p_accounting_mode       IN VARCHAR2
,p_gl_posting_flag       IN VARCHAR2
,p_accounting_batch_id   IN OUT NOCOPY INTEGER
,p_errbuf                IN OUT NOCOPY VARCHAR2
,p_retcode               IN OUT NOCOPY INTEGER
)
IS
CURSOR c_invalid_events IS
  SELECT 1
    FROM xla_acct_prog_events_gt            xap
       , xla_events                         xe
   WHERE xe.application_id                  = p_application_id
     AND xe.event_id                        = xap.event_id
     AND NVL(xe.budgetary_control_flag,'N') = DECODE(p_accounting_mode
                                                    ,'DRAFT','Y'      -- 5109240a replace 'D'
                                                    ,'FINAL','Y'      -- 5109240a replace 'F'
                                                    ,'N')
     AND ROWNUM = 1;

l_dummy            INTEGER;
l_count            INTEGER;
l_log_module       VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_program_events';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure accounting_program_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

      -- 7193986 start


      INSERT INTO xla_evt_class_orders_gt
         (event_class_code
         ,processing_order
         )
         SELECT xec.event_class_code
              , NVL(t.max_level, -1)
           FROM xla_event_classes_b xec
              , (SELECT application_id, event_class_code, max(LEVEL) AS max_level
                   FROM (SELECT application_id, event_class_code, prior_event_class_code
                           FROM xla_event_class_predecs
                          WHERE application_id = p_application_id
                          UNION
                         SELECT application_id, prior_event_class_code, NULL
                           FROM xla_event_class_predecs
                          WHERE application_id = p_application_id) xep
                   CONNECT BY application_id         = PRIOR application_id
                          AND prior_event_class_code = PRIOR event_class_code
                    GROUP BY application_id, event_class_code) t
          WHERE xec.event_class_code = t.event_class_code(+)
            AND xec.application_id   = t.application_id(+)
            AND xec.application_id   = p_application_id
            AND xec.event_class_code <> 'MANUAL';


       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of rows inserted into xla_evt_class_orders_gt = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
       END IF;

        -- 7193986 end







   UPDATE xla_acct_prog_events_gt xpa
      SET (ledger_id) =
          (SELECT ledger_id
             FROM xla_events xe
                , xla_transaction_entities xte
            WHERE xte.application_id = xe.application_id
              AND xte.entity_id      = xe.entity_id
              AND xe.application_id  = p_application_id
              AND xe.event_id        = xpa.event_id);

   SELECT count(*) into l_count
     FROM xla_acct_prog_events_gt
    WHERE ledger_id IS NULL;

   OPEN c_invalid_events;
   FETCH c_invalid_events INTO l_dummy;
   CLOSE c_invalid_events;

   IF (l_dummy IS NOT NULL) THEN
    --IF (p_accounting_mode in ('D', 'F')) THEN
      IF (p_accounting_mode in ('DRAFT', 'FINAL')) THEN  -- 5109240a
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace
             (p_msg      => 'Error: XLA_AP_INV_EVENT_MODE_NON_BC'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
        END IF;

        xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_INV_EVENT_MODE_NON_BC'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pub_pkg.accounting_program_events'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Budgetary control events exists for non-budgetary control mode');
      ELSE
        IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace
             (p_msg      => 'Error: XLA_AP_INV_EVENT_MODE_BC'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
        END IF;

        xla_exceptions_pkg.raise_message
            (p_appli_s_name   => 'XLA'
            ,p_msg_name       => 'XLA_AP_INV_EVENT_MODE_BC'
            ,p_token_1        => 'LOCATION'
            ,p_value_1        => 'xla_accounting_pub_pkg.accounting_program_events'
            ,p_token_2        => 'ERROR'
            ,p_value_2        => 'Non-budgetary control events exists for budgetary control mode');
      END IF;
   END IF;

   xla_accounting_pkg.accounting_program_events
           (p_application_id      => p_application_id
           ,p_accounting_mode     => p_accounting_mode
           ,p_gl_posting_flag     => p_gl_posting_flag
           ,p_offline_flag        => 'N'
           ,p_accounting_batch_id => p_accounting_batch_id
           ,p_errbuf              => p_errbuf
           ,p_retcode             => p_retcode);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure accounting_program_events'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_accounting_pub_pkg.accounting_program_events');
END accounting_program_events; -- end of procedure


--=============================================================================
--
--
--
--    Function is_historic_upgrade_running
--
--
--
--=============================================================================

FUNCTION is_historic_upgrade_running
    (
    p_ledger_id     IN  NUMBER
    ) RETURN BOOLEAN
  IS
  l_count     NUMBER := 0;
  l_log_module VARCHAR2(240);

  BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.is_historic_upgrade_running';
   END IF;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Begin of is_historic_upgrade_running'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;

  xla_environment_pkg.Refresh;

  -- Check if any historic upgrade has been submitted for the same ledger as the current one .


    select count(*) into l_count from dual
    where exists (select 1 from gl_ledger_relationships
                  where  primary_ledger_id = p_ledger_id and hist_conv_status_code = 'RUNNING');

    IF (l_count =1) THEN
       RETURN (TRUE);
    ELSE
       RETURN (FALSE);
    END IF;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'End of is_historic_upgrade_running'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     END IF;

  END is_historic_upgrade_running;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

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
-- Following code is executed when the package body is referenced for the first
-- time
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

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   g_log_level      := C_LEVEL_STATEMENT;
   g_log_enabled    := TRUE;

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_accounting_pub_pkg; -- end of package body

/
