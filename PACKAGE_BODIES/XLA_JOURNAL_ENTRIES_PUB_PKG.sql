--------------------------------------------------------
--  DDL for Package Body XLA_JOURNAL_ENTRIES_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_JOURNAL_ENTRIES_PUB_PKG" AS
/* $Header: xlajejep.pkb 120.8 2006/05/30 16:51:14 wychan ship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_journal_entries_pub_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
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
      (p_location   => 'xla_journal_entries_pub_pkg.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================


--=============================================================================
--
-- Following are the routines on which created for public manual journal
-- entries APIs.
--
--    1.    create_journal_entry_header
--    2.    create_journal_entry_line
--    3.    complete_journal_entry
--
--
--=============================================================================


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE create_journal_entry_header
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER
  ,p_gl_date                    IN  DATE
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER
  ,p_reference_date             IN  DATE
  ,p_budgetary_control_flag     IN  VARCHAR2
  ,p_attribute_category		IN  VARCHAR2
  ,p_attribute1			IN  VARCHAR2
  ,p_attribute2			IN  VARCHAR2
  ,p_attribute3			IN  VARCHAR2
  ,p_attribute4			IN  VARCHAR2
  ,p_attribute5			IN  VARCHAR2
  ,p_attribute6			IN  VARCHAR2
  ,p_attribute7			IN  VARCHAR2
  ,p_attribute8			IN  VARCHAR2
  ,p_attribute9			IN  VARCHAR2
  ,p_attribute10		IN  VARCHAR2
  ,p_attribute11		IN  VARCHAR2
  ,p_attribute12		IN  VARCHAR2
  ,p_attribute13		IN  VARCHAR2
  ,p_attribute14		IN  VARCHAR2
  ,p_attribute15		IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_ae_header_id		OUT NOCOPY INTEGER
  ,x_event_id			OUT NOCOPY INTEGER
)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'create_journal_entry_header';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           INTEGER;
  l_log_module        VARCHAR2(240);

  l_period_name      gl_period_statuses.period_name%TYPE;
  l_creation_date      DATE;
  l_created_by         INTEGER;
  l_last_update_date   DATE;
  l_last_updated_by    INTEGER;
  l_last_update_login  INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_journal_entry_header';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Calling xla_journal_entries_pkg.create_journal_entry_header',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  xla_journal_entries_pkg.create_journal_entry_header
  (p_application_id             => p_application_id
  ,p_ledger_id                  => p_ledger_id
  ,p_legal_entity_id            => p_legal_entity_id
  ,p_gl_date                    => p_gl_date
  ,p_accounting_entry_type_code	=> 'MANUAL'
  ,p_description                => p_description
  ,p_je_category_name           => p_je_category_name
  ,p_balance_type_code          => p_balance_type_code
  ,p_budget_version_id          => p_budget_version_id
  ,p_reference_date             => p_reference_date
  ,p_attribute_category		=> p_attribute_category
  ,p_attribute1			=> p_attribute1
  ,p_attribute2			=> p_attribute2
  ,p_attribute3			=> p_attribute3
  ,p_attribute4			=> p_attribute4
  ,p_attribute5			=> p_attribute5
  ,p_attribute6			=> p_attribute6
  ,p_attribute7			=> p_attribute7
  ,p_attribute8			=> p_attribute8
  ,p_attribute9			=> p_attribute9
  ,p_attribute10		=> p_attribute10
  ,p_attribute11		=> p_attribute11
  ,p_attribute12		=> p_attribute12
  ,p_attribute13		=> p_attribute13
  ,p_attribute14		=> p_attribute14
  ,p_attribute15		=> p_attribute15
  ,p_budgetary_control_flag     => p_budgetary_control_flag
  ,p_ae_header_id		=> x_ae_header_id
  ,p_event_id			=> x_event_id
  ,p_period_name                => l_period_name
  ,p_creation_date              => l_creation_date
  ,p_created_by                 => l_created_by
  ,p_last_update_date           => l_last_update_date
  ,p_last_updated_by            => l_last_updated_by
  ,p_last_update_login          => l_last_update_login
  ,p_retcode			=> l_retcode
  ,p_msg_mode			=> xla_datafixes_pub.g_msg_mode);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Returned from xla_journal_entries_pkg.create_journal_entry_header',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF l_retcode = 0 and x_ae_header_id IS NOT NULL THEN
     xla_datafixes_pub.audit_datafix (p_application_id  => p_application_id
                                     ,p_ae_header_id    => x_ae_header_id
                                     ,p_event_id        => x_event_id);
  ELSE
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Failed to create journal entry.',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
                                ,p_error_msg => 'Failed to create journal entry.');
  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

END create_journal_entry_header;




--=============================================================================
--
--
--
--=============================================================================

PROCEDURE create_journal_entry_line
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id		IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_displayed_line_number	IN  INTEGER
  ,p_code_combination_id        IN  INTEGER
  ,p_gl_transfer_mode          	IN  VARCHAR2
  ,p_accounting_class_code	IN  VARCHAR2
  ,p_currency_code          	IN  VARCHAR2
  ,p_entered_dr          	IN  NUMBER
  ,p_entered_cr	       		IN  NUMBER
  ,p_accounted_dr		IN  NUMBER
  ,p_accounted_cr		IN  NUMBER
  ,p_conversion_type		IN  VARCHAR2
  ,p_conversion_date   		IN  DATE
  ,p_conversion_rate   		IN  NUMBER
  ,p_party_type_code          	IN  VARCHAR2
  ,p_party_id          		IN  INTEGER
  ,p_party_site_id          	IN  INTEGER
  ,p_description          	IN  VARCHAR2
  ,p_statistical_amount         IN  NUMBER
  ,p_jgzz_recon_ref          	IN  VARCHAR2
  ,p_attribute_category		IN  VARCHAR2
  ,p_encumbrance_type_id        IN  INTEGER
  ,p_attribute1			IN  VARCHAR2
  ,p_attribute2			IN  VARCHAR2
  ,p_attribute3			IN  VARCHAR2
  ,p_attribute4			IN  VARCHAR2
  ,p_attribute5			IN  VARCHAR2
  ,p_attribute6			IN  VARCHAR2
  ,p_attribute7			IN  VARCHAR2
  ,p_attribute8			IN  VARCHAR2
  ,p_attribute9			IN  VARCHAR2
  ,p_attribute10		IN  VARCHAR2
  ,p_attribute11		IN  VARCHAR2
  ,p_attribute12		IN  VARCHAR2
  ,p_attribute13		IN  VARCHAR2
  ,p_attribute14		IN  VARCHAR2
  ,p_attribute15		IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_ae_line_num             	OUT NOCOPY INTEGER
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'create_journal_entry_line';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_entered_dr      NUMBER;
  l_entered_cr      NUMBER;
  l_currency_code   VARCHAR2(30);
  l_accounted_dr    NUMBER;
  l_accounted_cr    NUMBER;
  l_conversion_type VARCHAR2(30);
  l_conversion_date DATE;
  l_conversion_rate NUMBER;
  l_retcode         INTEGER;
  l_process_status     VARCHAR2(1);

  l_log_module      VARCHAR2(240);

  l_creation_date      DATE;
  l_created_by         INTEGER;
  l_last_update_date   DATE;
  l_last_updated_by    INTEGER;
  l_last_update_login  INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_journal_entry_line';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function create_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  -----------------------------------------------------------------------------------
  -- Validation
  -----------------------------------------------------------------------------------
  SELECT evt.process_status_code
  INTO   l_process_status
  FROM   xla_ae_headers xah, xla_events evt
  WHERE  xah.application_id = p_application_id
  AND    xah.ae_header_id   = p_ae_header_id
  AND    evt.application_id = p_application_id
  AND    xah.event_id       = evt.event_id;

  IF l_process_status <> 'U'  THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Entry is already processed.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
              ,p_error_msg => 'Entry is already processed.');
  END IF;

  IF p_accounting_class_code IN ('ROUNDING', 'BALANCE', 'INTRA', 'INTER') THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'The amount type '||p_accounting_class_code||' is not allowed.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    =>l_log_module
                                ,p_error_msg =>'The amount type '||p_accounting_class_code||' is not allowed.');
  END IF;

  l_entered_dr      := p_entered_dr;
  l_entered_cr      := p_entered_cr;
  l_currency_code   := p_currency_code;
  l_accounted_dr    := p_accounted_dr;
  l_accounted_cr    := p_accounted_cr;
  l_conversion_type := p_conversion_type;
  l_conversion_date := p_conversion_date;
  l_conversion_rate := p_conversion_rate;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling xla_journal_entries_pkg.create_journal_entry_line',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  xla_journal_entries_pkg.create_journal_entry_line
        (p_ae_header_id         => p_ae_header_id
        ,p_displayed_line_number=> p_displayed_line_number
        ,p_application_id       => p_application_id
        ,p_code_combination_id  => p_code_combination_id
        ,p_gl_transfer_mode     => p_gl_transfer_mode
        ,p_accounting_class_code=> p_accounting_class_code
        ,p_entered_dr          	=> l_entered_dr
        ,p_entered_cr	       	=> l_entered_cr
        ,p_currency_code        => l_currency_code
        ,p_accounted_dr		=> l_accounted_dr
        ,p_accounted_cr		=> l_accounted_cr
        ,p_conversion_type	=> l_conversion_type
        ,p_conversion_date   	=> l_conversion_date
        ,p_conversion_rate   	=> l_conversion_rate
        ,p_party_type_code      => p_party_type_code
        ,p_party_id          	=> p_party_id
        ,p_party_site_id        => p_party_site_id
        ,p_description          => p_description
        ,p_statistical_amount   => p_statistical_amount
        ,p_jgzz_recon_ref       => p_jgzz_recon_ref
        ,p_attribute_category	=> p_attribute_category
        ,p_encumbrance_type_id  => p_encumbrance_type_id
        ,p_attribute1		=> p_attribute1
        ,p_attribute2		=> p_attribute2
        ,p_attribute3		=> p_attribute3
        ,p_attribute4		=> p_attribute4
        ,p_attribute5		=> p_attribute5
        ,p_attribute6		=> p_attribute6
        ,p_attribute7		=> p_attribute7
        ,p_attribute8		=> p_attribute8
        ,p_attribute9		=> p_attribute9
        ,p_attribute10		=> p_attribute10
        ,p_attribute11		=> p_attribute11
        ,p_attribute12		=> p_attribute12
        ,p_attribute13		=> p_attribute13
        ,p_attribute14		=> p_attribute14
        ,p_attribute15		=> p_attribute15
        ,p_ae_line_num          => x_ae_line_num
        ,p_creation_date        => l_creation_date
        ,p_created_by           => l_created_by
        ,p_last_update_date     => l_last_update_date
        ,p_last_updated_by      => l_last_updated_by
        ,p_last_update_login    => l_last_update_login
        ,p_retcode              => l_retcode
        ,p_msg_mode             => xla_datafixes_pub.g_msg_mode);

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Returned from xla_journal_entries_pkg.create_journal_entry_line',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF l_retcode = 0 and x_ae_line_num IS NOT NULL THEN
     xla_datafixes_pub.audit_datafix (p_application_id => p_application_id
                                     ,p_ae_header_id   => p_ae_header_id
                                     ,p_ae_line_num    => x_ae_line_num);

  ELSE
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Failed to create journal line.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
           ,p_error_msg => 'Failed to create journal line.');
  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function create_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

END create_journal_entry_line;




--=============================================================================
--
--
--
--=============================================================================
PROCEDURE complete_journal_entry
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_completion_retcode         OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'complete_journal_entry';
  l_api_version       CONSTANT NUMBER       := 1.0;

  CURSOR c_funct_curr IS
    SELECT xgl.currency_code, xsu.je_source_name
      FROM xla_gl_ledgers_v xgl
         , xla_ae_headers   xah
         , xla_events       evt
         , xla_subledgers   xsu
     WHERE xgl.ledger_id      = xah.ledger_id
       AND xsu.application_id = xah.application_id
       AND xah.ae_header_id   = p_ae_header_id
       AND xah.application_id = p_application_id
       AND evt.process_status_code = 'U'
       AND evt.application_id = p_application_id
       AND xah.event_id       = evt.event_id;

  l_log_module      VARCHAR2(240);

  l_functional_curr            VARCHAR2(30);
  l_je_source_name             VARCHAR2(30);
  l_ae_status_code             VARCHAR2(30);
  l_funds_status_code          VARCHAR2(30);
  l_completion_seq_value       VARCHAR2(100); -- Should this be INTEGER or VARCHAR2 ? (see l_seq_values t_array_int?)
  l_completion_seq_ver_id      INTEGER;
  l_completed_date             DATE;
  l_gl_transfer_status_code    VARCHAR2(30);
  l_last_update_date           DATE;
  l_last_updated_by            INTEGER;
  l_last_update_login          INTEGER;
  l_transfer_request_id        INTEGER;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.complete_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;
  x_completion_retcode   := 'S';


  -------------------------------------------------------
  -- Validation
  -------------------------------------------------------
  OPEN c_funct_curr;
  FETCH c_funct_curr INTO l_functional_curr, l_je_source_name;
  IF c_funct_curr%NOTFOUND THEN
     CLOSE c_funct_curr;
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'There is no such journal entry or it is processed. Please verify.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
                                ,p_error_msg => 'There is no such journal entry or it is processed. Please verify.');
  END IF;
  CLOSE c_funct_curr;
  -------------------------------------------------------

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Calling xla_journal_entries_pkg.complete_journal_entry',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;
  xla_journal_entries_pkg.complete_journal_entry
       (p_ae_header_id               => p_ae_header_id
       ,p_application_id	     => p_application_id
       ,p_completion_option          => p_completion_option
       ,p_functional_curr            => l_functional_curr
       ,p_je_source_name             => l_je_source_name
       ,p_ae_status_code             => l_ae_status_code
       ,p_funds_status_code          => l_funds_status_code
       ,p_completion_seq_value       => l_completion_seq_value
       ,p_completion_seq_ver_id      => l_completion_seq_ver_id
       ,p_completed_date             => l_completed_date
       ,p_gl_transfer_status_code    => l_gl_transfer_status_code
       ,p_last_update_date           => l_last_update_date
       ,p_last_updated_by            => l_last_updated_by
       ,p_last_update_login          => l_last_update_login
       ,p_transfer_request_id        => l_transfer_request_id
       ,p_retcode		     => x_completion_retcode
       ,p_msg_mode		     => xla_datafixes_pub.g_msg_mode);
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Returned from xla_journal_entries_pkg.complete_journal_entry',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF x_completion_retcode = 'S' THEN
     xla_datafixes_pub.audit_datafix (p_application_id => p_application_id
                                     ,p_ae_header_id   => p_ae_header_id);

  ELSE
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace(p_msg    => 'Failed to complete journal entry.',
               p_module => l_log_module,
               p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
                                ,p_error_msg => 'Failed to complete journal entry.');

  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
  x_completion_retcode   := 'X';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
  x_completion_retcode   := 'X';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_completion_retcode   := 'X';
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

END complete_journal_entry;



--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_journal_entries_pub_pkg;

/
