--------------------------------------------------------
--  DDL for Package Body XLA_JOURNAL_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_JOURNAL_ENTRIES_PKG" AS
/* $Header: xlajejey.pkb 120.95.12010000.14 2010/03/26 05:32:34 karamakr ship $ */

-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------

TYPE t_je_info IS RECORD
  (header_id                    INTEGER
  ,ledger_id                    INTEGER
  ,legal_entity_id		INTEGER
  ,application_id               INTEGER
  ,entity_id                    INTEGER
  ,event_id                     INTEGER
  ,gl_date                      DATE
  ,status_code                  VARCHAR2(30)
  ,type_code                    VARCHAR2(30)
  ,description                  VARCHAR2(2400)
  ,balance_type_code            VARCHAR2(30)
  ,budget_version_id            INTEGER
  ,reference_date               DATE
  ,funds_status_code            VARCHAR2(30)
  ,je_category_name             VARCHAR2(80)
  ,packet_id                    INTEGER
  ,amb_context_code		VARCHAR2(30)
  ,event_type_code		VARCHAR2(30)
  ,completed_date		DATE
  ,gl_transfer_status_code	VARCHAR2(30)
  ,accounting_batch_id		INTEGER
  ,period_name			VARCHAR2(15)
  ,product_rule_code		VARCHAR2(30)
  ,product_rule_type_code	VARCHAR2(30)
  ,product_rule_version		VARCHAR2(30)
  ,gl_transfer_date		DATE
  ,doc_sequence_id		INTEGER
  ,doc_sequence_value		VARCHAR2(240)
  ,close_acct_seq_version_id	INTEGER
  ,close_acct_seq_value		VARCHAR2(240)
  ,close_acct_seq_assign_id	INTEGER
  ,completion_acct_seq_version_id INTEGER
  ,completion_acct_seq_value	VARCHAR2(240)
  ,completion_acct_seq_assign_id INTEGER
  ,accrual_reversal_flag        VARCHAR2(1)   -- 4262811
  ,budgetary_control_flag       VARCHAR2(1)
  ,attribute_category		VARCHAR2(30)
  ,attribute1			VARCHAR2(150)
  ,attribute2			VARCHAR2(150)
  ,attribute3			VARCHAR2(150)
  ,attribute4			VARCHAR2(150)
  ,attribute5			VARCHAR2(150)
  ,attribute6			VARCHAR2(150)
  ,attribute7			VARCHAR2(150)
  ,attribute8			VARCHAR2(150)
  ,attribute9			VARCHAR2(150)
  ,attribute10			VARCHAR2(150)
  ,attribute11			VARCHAR2(150)
  ,attribute12			VARCHAR2(150)
  ,attribute13			VARCHAR2(150)
  ,attribute14			VARCHAR2(150)
  ,attribute15			VARCHAR2(150));

TYPE t_array_number IS TABLE of NUMBER				INDEX BY BINARY_INTEGER;
TYPE t_array_date IS TABLE of DATE 				INDEX BY BINARY_INTEGER;
TYPE t_array_varchar IS TABLE of VARCHAR2(30)			INDEX BY BINARY_INTEGER;

TYPE t_array_int IS TABLE of INTEGER				INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
--
--
--
--
--
--
-- forward declarion of private procedures and functions
--
--
--
--
--
--
-------------------------------------------------------------------------------
FUNCTION get_header_info
  (p_ae_header_id       IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2)
RETURN t_je_info;

FUNCTION round_currency
  (p_amount         IN NUMBER
  ,p_currency_code  IN VARCHAR2
  ,p_rounding_rule_code IN VARCHAR2)
RETURN NUMBER;

PROCEDURE validate_line_number
  (p_header_id     	IN  INTEGER
  ,p_line_num		IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE validate_display_line_number
  (p_header_id     	IN  INTEGER
  ,p_line_num		IN  INTEGER
  ,p_display_line_num	IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE validate_ae_type_code
  (p_accounting_entry_type_code IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE validate_ae_status_code
   (p_status_code       IN  VARCHAR2
   ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

/*
FUNCTION unreserve_funds
   (p_ae_header_id      IN  INTEGER
   ,p_application_id    IN  INTEGER
   ,p_ledger_id         IN  INTEGER
   ,p_packet_id         IN  INTEGER
   ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
RETURN BOOLEAN;
*/

FUNCTION validate_completion_action
   (p_entity_id		IN  INTEGER
   ,p_event_id		IN  INTEGER
   ,p_ledger_id		IN  INTEGER
   ,p_ae_header_id	IN  INTEGER
   ,p_completion_option IN  VARCHAR2)
RETURN INTEGER;

FUNCTION validate_reversal_method
   (p_entity_id		IN  INTEGER
   ,p_event_id		IN  INTEGER
   ,p_ledger_id		IN  INTEGER
   ,p_ae_header_id	IN  INTEGER
   ,p_reversal_method	IN  VARCHAR2)
RETURN INTEGER;

FUNCTION is_budgetary_control_enabled
   (p_ledger_id		IN  INTEGER
   ,p_msg_mode		IN  VARCHAR2)
RETURN BOOLEAN;

PROCEDURE create_reversal_entry
  (p_info	        IN  t_je_info
  ,p_reversal_method	IN  VARCHAR2
  ,p_gl_date		IN  DATE
  ,p_msg_mode           IN  VARCHAR2
  ,p_rev_header_id	OUT NOCOPY INTEGER
  ,p_rev_event_id	OUT NOCOPY INTEGER);

FUNCTION reserve_funds
  (p_info	         IN OUT NOCOPY t_je_info
  ,p_msg_mode            IN            VARCHAR2)
RETURN VARCHAR2;

FUNCTION populate_sequence_numbers
 (p_info                 IN            t_je_info
 ,p_je_source_name       IN            VARCHAR2
 ,p_completed_date       IN            DATE
 ,p_ledger_ids           IN            xla_je_validation_pkg.t_array_int
 ,p_ae_header_ids        IN            xla_je_validation_pkg.t_array_int
 ,p_status_codes         IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar
 ,p_seq_version_ids      IN OUT NOCOPY t_array_int
 ,p_seq_values           IN OUT NOCOPY t_array_int
 ,p_seq_assign_ids       IN OUT NOCOPY t_array_int)
RETURN VARCHAR2;


PROCEDURE complete_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr            IN  VARCHAR2
  ,p_je_source_name             IN  VARCHAR2
  ,p_ae_status_code             OUT NOCOPY VARCHAR2
  ,p_funds_status_code          OUT NOCOPY VARCHAR2
  ,p_completion_seq_value       OUT NOCOPY VARCHAR2
  ,p_completion_seq_ver_id      OUT NOCOPY INTEGER
  ,p_completed_date             OUT NOCOPY DATE
  ,p_gl_transfer_status_code    OUT NOCOPY VARCHAR2
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_transfer_request_id        OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY VARCHAR2
  ,p_msg_mode                   IN  VARCHAR2    DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_flag                   IN  VARCHAR2 DEFAULT 'N'
  ,p_rev_method                 IN  VARCHAR2 DEFAULT 'N'
  ,p_rev_orig_event_id          IN  NUMBER DEFAULT -1);

PROCEDURE create_mrc_reversal_entry
  (p_info               IN  t_je_info
  ,p_reversal_method    IN  VARCHAR2
  ,p_orig_event_id      IN  NUMBER
  ,p_ledger_ids         IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_rev_ae_header_ids  IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_rev_status_codes   IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar);


FUNCTION create_mrc_entries
  (p_info		IN OUT NOCOPY t_je_info
  ,p_je_source_name	IN            VARCHAR2
  ,p_ledger_ids         IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_ae_header_ids      IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_status_codes       IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar)
RETURN VARCHAR2;

PROCEDURE delete_mrc_entries
  (p_event_id		IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_ledger_id		IN  INTEGER);

PROCEDURE update_event_status
 (p_info                IN t_je_info
 ,p_completion_option   IN VARCHAR2);

PROCEDURE transfer_to_gl
 (p_info                IN t_je_info
 ,p_application_id      IN INTEGER
 ,p_completion_option   IN VARCHAR2
 ,p_transfer_request_id IN OUT NOCOPY INTEGER);

PROCEDURE update_segment_values
  (p_ae_header_id	IN  INTEGER
  ,p_seg_type		IN  VARCHAR2
  ,p_seg_value		IN  VARCHAR2
  ,p_action		IN  VARCHAR2);

PROCEDURE validate_delete_mode
  (p_status_code	IN  VARCHAR2
  ,p_mode 		IN  VARCHAR2
  ,p_msg_mode		IN  VARCHAR2);

PROCEDURE validate_balance_type_code
  (p_balance_type_code	IN  VARCHAR2
  ,p_msg_mode		IN  VARCHAR2 DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

FUNCTION validate_description
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_description  	IN  VARCHAR2)
RETURN INTEGER;

FUNCTION validate_legal_entity_id
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_legal_entity_id  	IN  INTEGER)
RETURN INTEGER;

PROCEDURE get_ledger_info
  (p_ledger_id			IN  INTEGER
  ,p_application_id      	IN  INTEGER
  ,p_code_combination_id	IN  INTEGER
  ,p_funct_curr			OUT NOCOPY VARCHAR2
  ,p_rounding_rule_code		OUT NOCOPY VARCHAR2
  ,p_bal_seg_val		OUT NOCOPY VARCHAR2
  ,p_mgt_seg_val		OUT NOCOPY VARCHAR2);

PROCEDURE get_ledger_options
  (p_application_id            IN INTEGER
  ,p_ledger_id                 IN INTEGER
  ,p_transfer_to_gl_mode_code  OUT NOCOPY VARCHAR2);

FUNCTION clear_errors
   (p_event_id		IN  INTEGER
   ,p_ae_header_id	IN  INTEGER
   ,p_ae_line_num	IN  INTEGER)
RETURN BOOLEAN;

PROCEDURE validate_je_category
  (p_je_category_name	IN  VARCHAR2
  ,p_msg_mode		IN  VARCHAR2);

PROCEDURE validate_application_id
  (p_application_id     IN  INTEGER);

PROCEDURE validate_code_combination_id
   (p_line_num              IN  INTEGER
   ,p_code_combination_id   IN  INTEGER
   ,p_msg_mode		    IN  VARCHAR2 DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

FUNCTION validate_lines
   (p_entity_id		IN  INTEGER
   ,p_event_id		IN  INTEGER
   ,p_ledger_id		IN  INTEGER
   ,p_application_id	IN  INTEGER
   ,p_ae_header_id	IN  INTEGER)
RETURN INTEGER;

PROCEDURE validate_ledger
  (p_ledger_id              IN  INTEGER
  ,p_balance_type_code      IN  VARCHAR2
  ,p_budgetary_control_flag IN  VARCHAR2);

FUNCTION validate_line_counts
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_application_id  	IN  INTEGER
  ,p_balance_type_code  IN  VARCHAR2)
RETURN INTEGER;

PROCEDURE calculate_amounts
  (p_entered_dr           IN OUT NOCOPY NUMBER
  ,p_entered_cr           IN OUT NOCOPY NUMBER
  ,p_currency_code        IN OUT NOCOPY VARCHAR2
  ,p_functional_curr      IN VARCHAR2
  ,p_rounding_rule_code	  IN VARCHAR2
  ,p_accounted_dr         IN OUT NOCOPY NUMBER
  ,p_accounted_cr         IN OUT NOCOPY NUMBER
  ,p_unrounded_entered_dr IN OUT NOCOPY NUMBER
  ,p_unrounded_entered_cr IN OUT NOCOPY NUMBER
  ,p_unrounded_accted_dr  IN OUT NOCOPY NUMBER
  ,p_unrounded_accted_cr  IN OUT NOCOPY NUMBER
  ,p_conv_type            IN OUT NOCOPY VARCHAR2
  ,p_conv_date            IN OUT NOCOPY DATE
  ,p_conv_rate            IN OUT NOCOPY NUMBER);

FUNCTION validate_amounts
  (p_entity_id          IN  INTEGER
  ,p_event_id           IN  INTEGER
  ,p_ledger_id          IN  INTEGER
  ,p_ae_header_id       IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_functional_curr	IN  VARCHAR2)
RETURN INTEGER;

PROCEDURE reorder_line_number
  (p_application_id	IN  INTEGER
  ,p_ae_header_id	IN  INTEGER);

PROCEDURE undo_draft_entry
  (p_info	        IN  t_je_info);

FUNCTION get_period_name
  (p_ledger_id          IN  INTEGER
  ,p_accounting_date    IN  DATE
  ,p_closing_status     OUT NOCOPY VARCHAR2
  ,p_period_type        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

PROCEDURE create_distribution_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ae_line_num                IN  INTEGER
  ,p_temp_line_num              IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_ref_event_id               IN  INTEGER
  ,p_ref_temp_line_num          IN  INTEGER);

PROCEDURE delete_distribution_link
  (p_application_id		IN  INTEGER
  ,p_ae_header_id       IN  INTEGER
  ,p_ref_ae_header_id   IN  INTEGER
  ,p_temp_line_num      IN  INTEGER);

PROCEDURE update_distribution_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_temp_line_num             	IN  INTEGER
  ,p_unrounded_entered_dr       IN  NUMBER
  ,p_unrounded_entered_cr       IN  NUMBER
  ,p_unrounded_accounted_dr     IN  NUMBER
  ,p_undournde_accounted_cr     IN  NUMBER
  ,p_statistical_amount         IN  NUMBER);

PROCEDURE create_reversal_distr_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_ref_event_id               IN  INTEGER);

PROCEDURE get_rev_line_info
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER
  ,p_temp_line_num              IN OUT NOCOPY INTEGER
  ,p_ref_ae_header_id           OUT    NOCOPY INTEGER
  ,p_ref_event_id               OUT    NOCOPY INTEGER);

PROCEDURE get_mrc_rev_line_info
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER
  ,p_temp_line_num              IN OUT NOCOPY INTEGER
  ,p_ref_ae_header_id           OUT    NOCOPY INTEGER
  ,p_ref_temp_line_num          OUT    NOCOPY INTEGER
  ,p_ref_event_id               OUT    NOCOPY INTEGER);

FUNCTION is_reversal
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER
  ,p_temp_line_num              IN            INTEGER)
RETURN BOOLEAN;

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
C_AE_STATUS_INCOMPLETE          CONSTANT VARCHAR2(30) := 'N';
C_AE_STATUS_INVALID             CONSTANT VARCHAR2(30) := 'I';
C_AE_STATUS_RELATED             CONSTANT VARCHAR2(30) := 'R';
C_AE_STATUS_DRAFT               CONSTANT VARCHAR2(30) := 'D';
C_AE_STATUS_FINAL               CONSTANT VARCHAR2(30) := 'F';

C_EVENT_TYPE_CODE_MANUAL	CONSTANT VARCHAR2(30) := 'MANUAL';
C_EVENT_CLASS_CODE_MANUAL	CONSTANT VARCHAR2(30) := 'MANUAL';
C_ENTITY_TYPE_CODE_MANUAL	CONSTANT VARCHAR2(30) := 'MANUAL';

C_TYPE_MANUAL                   CONSTANT VARCHAR2(30)   := 'MANUAL';
C_TYPE_UPGRADE                  CONSTANT VARCHAR2(30)   := 'UPGRADE';
C_TYPE_MERGE                    CONSTANT VARCHAR2(30)   := 'MERGE';

C_GL_TRANSFER_MODE_NO		CONSTANT VARCHAR2(30) := 'N';
C_GL_TRANSFER_MODE_YES		CONSTANT VARCHAR2(30) := 'Y';
C_GL_TRANSFER_MODE_SELECTED	CONSTANT VARCHAR2(30) := 'S';
C_GL_APPLICATION_ID		CONSTANT INTEGER := 101;
C_XLA_APPLICATION_ID		CONSTANT INTEGER := 602;

C_ACTION_ADD			CONSTANT VARCHAR2(1) := 'A';
C_ACTION_DEL			CONSTANT VARCHAR2(1) := 'D';

C_JE_ACTUAL			CONSTANT VARCHAR2(30) := 'A';
C_JE_BUDGET			CONSTANT VARCHAR2(30) := 'B';
C_JE_ENCUMBRANCE		CONSTANT VARCHAR2(30) := 'E';

C_SEG_BALANCING			CONSTANT VARCHAR2(1) := 'B';
C_SEG_MANAGEMENT		CONSTANT VARCHAR2(1) := 'M';

C_GL_TRANSFER_SUMMARY		CONSTANT VARCHAR2(1) := 'S';
C_GL_TRANSFER_DETAIL		CONSTANT VARCHAR2(1) := 'D';

C_FUNDS_SUCCESS			CONSTANT VARCHAR2(1) := 'S';
C_FUNDS_ADVISORY		CONSTANT VARCHAR2(1) := 'A';
C_FUNDS_PARTIAL			CONSTANT VARCHAR2(1) := 'P';
C_FUNDS_FAILED			CONSTANT VARCHAR2(1) := 'F';

C_BALANCE_DELETE		CONSTANT VARCHAR2(1) := 'D';
C_BALANCE_ADD			CONSTANT VARCHAR2(1) := 'A';
C_BALANCE_D_TO_F		CONSTANT VARCHAR2(1) := 'F';

C_BALANCE_ONLINE		CONSTANT VARCHAR2(1) := 'O';

C_COMPLETION_OPTION_SAVE        CONSTANT VARCHAR2(1)    := 'S';
C_COMPLETION_OPTION_DRAFT       CONSTANT VARCHAR2(1)    := 'D';
C_COMPLETION_OPTION_FINAL       CONSTANT VARCHAR2(1)    := 'F';
C_COMPLETION_OPTION_TRANSFER    CONSTANT VARCHAR2(1)    := 'T';
C_COMPLETION_OPTION_POST        CONSTANT VARCHAR2(1)    := 'P';

C_REVERSAL_CHANGE_SIGN          CONSTANT VARCHAR2(30)    := 'SIGN';
C_REVERSAL_SWITCH_DR_CR         CONSTANT VARCHAR2(30)    := 'SIDE';

C_DELETE_FORCE_MODE             CONSTANT VARCHAR2(1)    := 'F';

C_NUM                           CONSTANT NUMBER      := 9.99E125;
C_CHAR                          CONSTANT VARCHAR2(1) := fnd_global.local_chr(12);
C_DATE                          CONSTANT DATE        := TO_DATE('1','j');

-- 5109240
C_ITEM_HEADER_DESCRIPTION       CONSTANT VARCHAR2(20) := 'HEADER_DESCRIPTION';
C_ITEM_GL_DATE                  CONSTANT VARCHAR2(20) := 'GL_DATE';
C_ITEM_REFERENCE_DATE           CONSTANT VARCHAR2(20) := 'REFERENCE_DATE';
C_ITEM_LINE_DESCRIPTION         CONSTANT VARCHAR2(20) := 'LINE_DESCRIPTION';
C_ITEM_ACCOUNT                  CONSTANT VARCHAR2(20) := 'ACCOUNT';
C_ITEM_ACCOUNTED_DR             CONSTANT VARCHAR2(20) := 'ACCOUNTED_DR';
C_ITEM_ACCOUNTED_CR             CONSTANT VARCHAR2(20) := 'ACCOUNTED_CR';
C_ITEM_CURRENCY_CODE            CONSTANT VARCHAR2(20) := 'CURRENCY_CODE';
C_ITEM_CURR_CONV_TYPE           CONSTANT VARCHAR2(20) := 'CURR_CONV_TYPE';
C_ITEM_CURR_CONV_RATE           CONSTANT VARCHAR2(20) := 'CURR_CONV_RATE';
C_ITEM_CURR_CONV_DATE           CONSTANT VARCHAR2(20) := 'CURR_CONV_DATE';
C_ITEM_ENTERED_DR               CONSTANT VARCHAR2(20) := 'ENTERED_DR';
C_ITEM_ENTERED_CR               CONSTANT VARCHAR2(20) := 'ENTERED_CR';
C_ITEM_ACCOUNTING_CLASS         CONSTANT VARCHAR2(20) := 'ACCOUNTING_CLASS';

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_journal_entries_pkg';

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
      (p_location   => 'xla_journal_entries_pkg.trace');
END trace;

--=============================================================================
--
--
--
--
--
--
--          *********** public procedures and functions **********
--
--
--
--
--
--
--=============================================================================


--=============================================================================
--
-- Following are the routines on which created for public manual journal
-- entries APIs.
--
--    1.    create_journal_entry_header
--    2.    create_journal_entry_line
--    3.    update_journal_entry_header
--    4.    update_journal_entry_line
--    5.    delete_journal_entry
--    6.    delete_journal_entry_line
--    7.    complete_journal_entry
--    8.    reverse_journal_entry
--
--
--=============================================================================


--=============================================================================
--
-- Name: create_journal_entry_header
-- Description: Create a journal entry header.
--              This API is called by MJE page, and the ledger determines if
--              budgetary control events is created for this JE.
--
--=============================================================================
PROCEDURE create_journal_entry_header
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER     DEFAULT NULL
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER     DEFAULT NULL
  ,p_reference_date             IN  DATE        DEFAULT NULL
  ,p_attribute_category         IN  VARCHAR2    DEFAULT NULL
  ,p_attribute1                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute2                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute3                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute4                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute5                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute6                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute7                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute8                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute9                 IN  VARCHAR2    DEFAULT NULL
  ,p_attribute10                IN  VARCHAR2    DEFAULT NULL
  ,p_attribute11                IN  VARCHAR2    DEFAULT NULL
  ,p_attribute12                IN  VARCHAR2    DEFAULT NULL
  ,p_attribute13                IN  VARCHAR2    DEFAULT NULL
  ,p_attribute14                IN  VARCHAR2    DEFAULT NULL
  ,p_attribute15                IN  VARCHAR2    DEFAULT NULL
  ,p_ae_header_id               OUT NOCOPY INTEGER
  ,p_event_id                   OUT NOCOPY INTEGER
  ,p_period_name                OUT NOCOPY VARCHAR2
  ,p_creation_date              OUT NOCOPY DATE
  ,p_created_by                 OUT NOCOPY INTEGER
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode                   IN  VARCHAR2    DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  CURSOR c IS
    SELECT enable_budgetary_control_flag
      FROM gl_ledgers
     WHERE ledger_id = p_ledger_id;

  l_bc_flag             VARCHAR2(1);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_journal_entry_header';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_bc_flag;
  CLOSE c;

  create_journal_entry_header
            (p_application_id             => p_application_id
            ,p_ledger_id                  => p_ledger_id
            ,p_legal_entity_id            => p_legal_entity_id
            ,p_gl_date                    => p_gl_date
            ,p_accounting_entry_type_code => p_accounting_entry_type_code
            ,p_description                => p_description
            ,p_je_category_name           => p_je_category_name
            ,p_balance_type_code          => p_balance_type_code
            ,p_budget_version_id          => p_budget_version_id
            ,p_reference_date             => p_reference_date
            ,p_attribute_category         => p_attribute_category
            ,p_attribute1                 => p_attribute1
            ,p_attribute2                 => p_attribute2
            ,p_attribute3                 => p_attribute3
            ,p_attribute4                 => p_attribute4
            ,p_attribute5                 => p_attribute5
            ,p_attribute6                 => p_attribute6
            ,p_attribute7                 => p_attribute7
            ,p_attribute8                 => p_attribute8
            ,p_attribute9                 => p_attribute9
            ,p_attribute10                => p_attribute10
            ,p_attribute11                => p_attribute11
            ,p_attribute12                => p_attribute12
            ,p_attribute13                => p_attribute13
            ,p_attribute14                => p_attribute14
            ,p_attribute15                => p_attribute15
            ,p_budgetary_control_flag     => l_bc_flag
            ,p_ae_header_id               => p_ae_header_id
            ,p_event_id                   => p_event_id
            ,p_period_name                => p_period_name
            ,p_creation_date              => p_creation_date
            ,p_created_by                 => p_created_by
            ,p_last_update_date           => p_last_update_date
            ,p_last_updated_by            => p_last_updated_by
            ,p_last_update_login          => p_last_update_login
            ,p_retcode                    => p_retcode
            ,p_msg_mode                   => p_msg_mode);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.create_journal_entry_header');

END create_journal_entry_header;

--=============================================================================
--
-- Name: create_journal_entry_header
-- Description: Create a journal entry header.
--              This API is called by the datafix public package, the caller
--              determines if the journal entry should be created as BC event.
--
--=============================================================================
PROCEDURE create_journal_entry_header
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code	IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER
  ,p_reference_date             IN  DATE
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
  ,p_budgetary_control_flag     IN  VARCHAR2
  ,p_ae_header_id		OUT NOCOPY INTEGER
  ,p_event_id			OUT NOCOPY INTEGER
  ,p_period_name		OUT NOCOPY VARCHAR2
  ,p_creation_date              OUT NOCOPY DATE
  ,p_created_by                 OUT NOCOPY INTEGER
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode			OUT NOCOPY INTEGER
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS

  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_entity_id		INTEGER;
  l_closing_status	VARCHAR2(30);
  l_status_code		VARCHAR2(30) := C_AE_STATUS_INCOMPLETE;
  l_result2		INTEGER := 0;
  l_period_type		VARCHAR2(30);

  l_budget_version_id	INTEGER;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_journal_entry_header';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  fnd_msg_pub.initialize;
  p_retcode := 0;

  --
  -- Validation where exception will be throw
  --
  validate_application_id(p_application_id);
  validate_ledger(p_ledger_id, p_balance_type_code, p_budgetary_control_flag);
  validate_je_category(p_je_category_name, p_msg_mode);
  validate_balance_type_code(p_balance_type_code, p_msg_mode);
  validate_ae_type_code(p_accounting_entry_type_code, p_msg_mode);

  -- Done validation

  IF (p_balance_type_code = C_JE_ACTUAL) THEN
    l_budget_version_id := NULL;
  ELSIF (p_balance_type_code = C_JE_BUDGET) THEN
    l_budget_version_id := p_budget_version_id;
  ELSE
    l_budget_version_id := NULL;
  END IF;

  --
  -- Create entity and event for the journal entry
  --
  l_event_source_info.application_id := p_application_id;
  l_event_source_info.legal_entity_id := p_legal_entity_id;
  l_event_source_info.ledger_id := p_ledger_id;
  l_event_source_info.entity_type_code := C_ENTITY_TYPE_CODE_MANUAL;

  p_event_id := xla_events_pkg.create_manual_event
   (p_event_source_info 	  => l_event_source_info
   ,p_event_type_code             => C_EVENT_TYPE_CODE_MANUAL
   ,p_event_date                  => p_gl_date
   ,p_event_status_code           => xla_events_pub_pkg.C_EVENT_UNPROCESSED
   ,p_process_status_code	  => xla_events_pkg.C_INTERNAL_UNPROCESSED
   ,p_event_number                => 1
   ,p_budgetary_control_flag      => p_budgetary_control_flag
   );

  SELECT 	entity_id
  INTO		l_entity_id
  FROM		xla_events
  WHERE		event_id = p_event_id;

  --
  -- Retrieve period name
  --
  p_period_name := get_period_name
	(p_ledger_id		=> p_ledger_id
	,p_accounting_date	=> p_gl_date
	,p_closing_status	=> l_closing_status
	,p_period_type		=> l_period_type);

  IF (p_period_name IS NULL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
	 ,p_msg_name		=> 'XLA_AP_INVALID_GL_DATE'
         ,p_token_1             => 'GL_DATE'
         ,p_value_1             => to_char(p_gl_date,'DD-MON-YYYY')
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  --
  -- Create entry in the xla_ae_headers table
  --
  INSERT INTO xla_ae_headers
     (ae_header_id
     ,application_id
     ,ledger_id
     ,entity_id
     ,event_id
     ,event_type_code
     ,accounting_date
     ,reference_date
     ,balance_type_code
     ,budget_version_id
     ,gl_transfer_status_code
     ,je_category_name
     ,accounting_entry_status_code
     ,accounting_entry_type_code
     ,description
     ,period_name
     ,attribute_category
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,accrual_reversal_flag    -- 4262811
  )
  values
     (xla_ae_headers_s.NEXTVAL
     ,p_application_id
     ,p_ledger_id
     ,l_entity_id
     ,p_event_id
     ,C_EVENT_TYPE_CODE_MANUAL
     ,p_gl_date
     ,p_reference_date
     ,p_balance_type_code
     ,l_budget_version_id
     ,C_GL_TRANSFER_MODE_NO
     ,p_je_category_name
     ,l_status_code
     ,p_accounting_entry_type_code
     ,p_description
     ,p_period_name
     ,p_attribute_category
     ,p_attribute1
     ,p_attribute2
     ,p_attribute3
     ,p_attribute4
     ,p_attribute5
     ,p_attribute6
     ,p_attribute7
     ,p_attribute8
     ,p_attribute9
     ,p_attribute10
     ,p_attribute11
     ,p_attribute12
     ,p_attribute13
     ,p_attribute14
     ,p_attribute15
     ,sysdate
     ,nvl(xla_environment_pkg.g_usr_id,-1)
     ,sysdate
     ,nvl(xla_environment_pkg.g_usr_id,-1)
     ,nvl(xla_environment_pkg.g_login_id,-1)
     ,'N')              -- 4262811 accrual_reversal_flag
     RETURNING 	 ae_header_id
	    	,creation_date
	    	,created_by
  	    	,last_update_date
	    	,last_updated_by
	    	,last_update_login
	INTO	 p_ae_header_id
		,p_creation_date
		,p_created_by
		,p_last_update_date
		,p_last_updated_by
		,p_last_update_login;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'header id = '||p_ae_header_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.create_journal_entry_header');

END create_journal_entry_header;




--=============================================================================
--
-- Name: update_journal_entry_header
-- Description: Update a journal entry header.
--
--=============================================================================
PROCEDURE update_journal_entry_header
  (p_ae_header_id               IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER	DEFAULT NULL
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code	IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER 	DEFAULT NULL
  ,p_reference_date             IN  DATE	DEFAULT NULL
  ,p_attribute_category		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute1			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute2			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute3			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute4			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute5			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute6			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute7			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute8			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute9			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute10		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute11		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute12		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute13		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute14		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute15		IN  VARCHAR2	DEFAULT NULL
  ,p_period_name		OUT NOCOPY VARCHAR2
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode			OUT NOCOPY INTEGER
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_info		t_je_info;
  l_status_code		VARCHAR2(30) := C_AE_STATUS_INCOMPLETE;
  l_closing_status	VARCHAR2(30);
  l_result2		INTEGER;
  l_period_type		VARCHAR2(30);

  l_budget_version_id	INTEGER;

  l_event_source_info	xla_events_pub_pkg.t_event_source_info;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_journal_entry_header';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  fnd_msg_pub.initialize;
  p_retcode := 0;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  --
  -- Validation where exception will be throw
  --
  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_ae_status_code(l_info.status_code, p_msg_mode);
  validate_je_category(p_je_category_name, p_msg_mode);
  -- Done Validation

  IF (l_info.balance_type_code = C_JE_ACTUAL) THEN
    l_budget_version_id := NULL;
  ELSIF (l_info.balance_type_code = C_JE_BUDGET) THEN
    l_budget_version_id := p_budget_version_id;
  ELSE
    l_budget_version_id := NULL;
  END IF;

  --
  -- Get Period Name
  --
  p_period_name := get_period_name
	(p_ledger_id		=> l_info.ledger_id
	,p_accounting_date	=> p_gl_date
	,p_closing_status	=> l_closing_status
	,p_period_type		=> l_period_type);

  IF (p_period_name IS NULL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
	 ,p_msg_name		=> 'XLA_AP_INVALID_GL_DATE'
         ,p_token_1             => 'GL_DATE'
         ,p_value_1             => to_char(p_gl_date,'DD-MON-YYYY')
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (l_info.status_code = C_AE_STATUS_INVALID ) THEN
    IF (NOT clear_errors(l_info.event_id, p_ae_header_id, NULL)) THEN
      l_status_code := C_AE_STATUS_INVALID;
    END IF;
  END IF;

  --
  -- Update xla_transaction_entities if ledger entity id is updated
  --
  IF (l_info.legal_entity_id <> p_legal_entity_id) THEN
    UPDATE xla_transaction_entities
	  SET	legal_entity_id		= p_legal_entity_id
	  WHERE	application_id	        = p_application_id   -- 4928660
          AND   entity_id		= l_info.entity_id;
  END IF;

  --
  -- Update xla_events if gl date is updated
  --
  IF (l_info.gl_date <> p_gl_date) THEN
    UPDATE xla_events
       SET event_date	  = p_gl_date
     WHERE application_id = p_application_id
       AND event_id       = l_info.event_id;

    UPDATE xla_ae_lines
       SET accounting_date = p_gl_date
     WHERE application_id  = p_application_id
       AND ae_header_id    = p_ae_header_id;
  END IF;

  --
  -- If the entry was a draft entry, undo draft
  --
  undo_draft_entry(l_info);

  --
  -- Update xla_ae_headers with modified information
  --
  UPDATE xla_ae_headers
	SET	 reference_date 		= p_reference_date
		,budget_version_id		= l_budget_version_id
  		,accounting_entry_type_code 	= p_accounting_entry_type_code
		,accounting_entry_status_code	= l_status_code
   		,accounting_date		= p_gl_date
		,period_name			= p_period_name
   		,je_category_name		= p_je_category_name
   		,description			= p_description
   		,last_update_date		= sysdate
   		,last_updated_by		= nvl(xla_environment_pkg.g_usr_id,-1)
   		,last_update_login		= nvl(xla_environment_pkg.g_login_id,-1)
		,attribute_category		= p_attribute_category
		,attribute1			= p_attribute1
		,attribute2			= p_attribute2
		,attribute3			= p_attribute3
		,attribute4			= p_attribute4
		,attribute5			= p_attribute5
		,attribute6			= p_attribute6
		,attribute7			= p_attribute7
		,attribute8			= p_attribute8
		,attribute9			= p_attribute9
		,attribute10			= p_attribute10
		,attribute11			= p_attribute11
		,attribute12			= p_attribute12
		,attribute13			= p_attribute13
		,attribute14			= p_attribute14
		,attribute15			= p_attribute15
	WHERE	ae_header_id			= p_ae_header_id
          AND	application_id			= p_application_id
     RETURNING 	 last_update_date
	    	,last_updated_by
	    	,last_update_login
	INTO	 p_last_update_date
		,p_last_updated_by
		,p_last_update_login;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_journal_entry_header',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;
WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.update_journal_entry_header');

END update_journal_entry_header;

--=============================================================================
--
-- Name: delete_journal_entry
-- Description: Delete a journal entry
--
--=============================================================================

PROCEDURE delete_journal_entry
  (p_ae_header_id		IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_mode			IN  VARCHAR2	DEFAULT C_DELETE_NORMAL_MODE
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_info		t_je_info;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  --
  -- Validation where exception will be throw
  --
  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_delete_mode(l_info.status_code, p_mode, p_msg_mode);

  l_event_source_info.application_id     := p_application_id;
  l_event_source_info.legal_entity_id    := l_info.legal_entity_id;
  l_event_source_info.ledger_id          := l_info.ledger_id;
  l_event_source_info.entity_type_code   := C_ENTITY_TYPE_CODE_MANUAL;

  IF (l_info.status_code = C_AE_STATUS_FINAL) THEN
    XLA_EVENTS_PKG.delete_processed_event
   	    (p_event_source_info            => l_event_source_info
   	    ,p_event_id                     => l_info.event_id);
  ELSE
    XLA_EVENTS_PKG.delete_event
   	    (p_event_source_info            => l_event_source_info
            ,p_valuation_method             => NULL
   	    ,p_event_id                     => l_info.event_id);
  END IF;

  -- Delete from Funda Checker entries
  psa_funds_checker_pkg.glxfpp(p_eventid => l_info.event_id);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.update_journal_entry_header');

END delete_journal_entry;


--=============================================================================
--
-- Name: delete_journal_entry
-- Description: Delete all journal entries of an event.
--
--=============================================================================
PROCEDURE delete_journal_entries
  (p_event_id                   IN  INTEGER
  ,p_application_id		IN  INTEGER)
IS
  CURSOR c_entries IS
    SELECT  h.ae_header_id                  ae_header_id
           ,e.ledger_id                     ledger_id
           ,h.accounting_entry_status_code  status_code
           ,h.accounting_entry_type_code    type_code
           ,h.funds_status_code             funds_status_code
           ,h.packet_id                     packet_id
           ,h.entity_id                     entity_id
      FROM xla_ae_headers                  h
          ,xla_transaction_entities        e
     WHERE e.application_id   = p_application_id
       AND e.entity_id        = h.entity_id
       AND h.application_id   = p_application_id
       AND h.event_id         = p_event_id
    FOR UPDATE NOWAIT;

  CURSOR c_period IS
    SELECT       'exist'
    FROM         xla_ae_headers h
		,gl_period_statuses p
    WHERE       p.application_id(+)       	= C_GL_APPLICATION_ID
      AND       p.ledger_id(+)             	= h.ledger_id
      AND       p.adjustment_period_flag(+) 	= 'N'
      AND	p.period_name(+)	     	= h.period_name
      AND	nvl(p.closing_status, 'C')   	NOT in ('0', 'F')
      AND	h.accounting_entry_status_code 	= C_AE_STATUS_FINAL
      AND       h.application_id		= p_application_id
      AND	h.event_id			= p_event_id;

  l_ae_header_ids       t_array_int;
  l_entry               c_entries%ROWTYPE;

  l_result		INTEGER;
  l_funds_retcode	VARCHAR2(30);
  l_open_retcode	INTEGER;
  l_period_name		VARCHAR2(30);

  l_error		VARCHAR(30);

  j			INTEGER := 0;
  k			INTEGER := 0;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_journal_entries';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_journal_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Ensure no Final journal entry within the event exists in a closed period
  --
  OPEN c_period;
  IF (c_period%FOUND) THEN
    CLOSE c_period;
    xla_exceptions_pkg.raise_message
            (p_appli_s_name     => 'XLA'
            ,p_msg_name         => 'XLA_MJE_CANT_DEL_CLOSED_PERIOD'
            ,p_msg_mode	        => xla_exceptions_pkg.C_STANDARD_MESSAGE);
  END IF;
  CLOSE c_period;

  OPEN c_entries;
  FETCH c_entries INTO l_entry;

 /*  -- Maintaining the Draft balance is no more required bug 5529569

  IF (l_entry.ae_header_id IS NOT NULL) THEN
    --
    -- If deleting a draft or final journal entry, DELETE the balance
    --
    IF (l_entry.status_code IN (C_AE_STATUS_DRAFT, C_AE_STATUS_FINAL)) THEN
      IF (NOT xla_balances_pkg.massive_update
	  		(p_application_id 	=> p_application_id
	  		,p_ledger_id		=> NULL
			,p_entity_id		=> l_entry.entity_id
   	  		,p_event_id		=> NULL
			,p_request_id		=> NULL
	  		,p_accounting_batch_id	=> NULL
   	  		,p_update_mode		=> C_BALANCE_DELETE
	  		,p_execution_mode	=> C_BALANCE_ONLINE)) THEN
        xla_exceptions_pkg.raise_message
          (p_appli_s_name	=> 'XLA'
          ,p_msg_name		=> 'XLA_INTERNAL_ERROR'
          ,p_token_1            => 'MESSAGE'
          ,p_value_1            => 'Error in balance calculation'
          ,p_token_2            => 'LOCATION'
          ,p_value_2            => 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entries'
	  ,p_msg_mode		=> xla_exceptions_pkg.C_STANDARD_MESSAGE);
      END IF;
    END IF;
  END IF;
*/
  WHILE (c_entries%FOUND) LOOP

    IF (nvl(l_entry.funds_status_code,C_CHAR) IN (C_FUNDS_SUCCESS, C_FUNDS_ADVISORY)) THEN
      PSA_FUNDS_CHECKER_PKG.glxfpp(p_eventid => p_event_id);
    END IF;

    j := j+1;
    l_ae_header_ids(j) := l_entry.ae_header_id;

    FETCH c_entries INTO l_entry;
  END LOOP;

  CLOSE c_entries;

  DELETE FROM xla_accounting_errors
     WHERE event_id = p_event_id;

  DELETE FROM xla_distribution_links
   WHERE application_id = p_application_id
     AND ae_header_id IN (SELECT ae_header_id
                            FROM xla_ae_headers
                           WHERE application_id = p_application_id
                             AND event_id       = p_event_id);

  IF (l_entry.ae_header_id IS NOT NULL) THEN

    FORALL k in 1..j
      DELETE FROM xla_ae_segment_values
       WHERE ae_header_id = l_ae_header_ids(k);

    FOR k in 1..j LOOP
      IF (NOT xla_analytical_criteria_pkg.single_update_detail_value
	(p_application_id		=> p_application_id
	,p_ae_header_id			=> l_ae_header_ids(k)
	,p_ae_line_num			=> NULL
	,p_anacri_code			=> NULL
	,p_anacri_type_code		=> NULL
	,p_amb_context_code		=> NULL
	,p_update_mode			=> 'D')) THEN
      ROLLBACK to SAVEPOINT DELETE_JOURNAL_ENTRIES;

      xla_exceptions_pkg.raise_message
         (p_appli_s_name        => 'XLA'
         ,p_msg_name            => 'XLA_COMMON_INTERNAL_ERROR'
         ,p_token_1            	=> 'MESSAGE'
         ,p_value_1            	=> 'Error in xla_analytical_criteria_pkg.single_update_detail_value'
         ,p_token_2            	=> 'LOCATION'
         ,p_value_2            	=> 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entries'
         ,p_msg_mode            => xla_exceptions_pkg.C_STANDARD_MESSAGE);
      END IF;
    END LOOP;

    FORALL k in 1..j
      DELETE FROM xla_ae_line_acs
       WHERE ae_header_id = l_ae_header_ids(k);

    FORALL k in 1..j
      DELETE FROM xla_ae_header_acs
       WHERE ae_header_id = l_ae_header_ids(k);

    FORALL k in 1..j
      DELETE FROM xla_ae_lines
      WHERE application_id = p_application_id
        AND ae_header_id = l_ae_header_ids(k);

    FORALL k in 1..j
      DELETE xla_ae_headers
      WHERE application_id = p_application_id
        AND ae_header_id = l_ae_header_ids(k);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_journal_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  IF (c_entries%ISOPEN) THEN
    CLOSE c_entries;
  END IF;
  IF (c_period%ISOPEN) THEN
    CLOSE c_period;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  IF (c_entries%ISOPEN) THEN
    CLOSE c_entries;
  END IF;
  IF (c_period%ISOPEN) THEN
    CLOSE c_period;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.delete_journal_entries');

END delete_journal_entries;


--=============================================================================
--
-- Name: create_journal_entry_line
-- Description: Create a journal entry line.
--
--=============================================================================

PROCEDURE create_journal_entry_line
  (p_ae_header_id               IN  INTEGER
  ,p_displayed_line_number	IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_code_combination_id        IN  INTEGER
  ,p_gl_transfer_mode          	IN  VARCHAR2
  ,p_accounting_class_code	IN  VARCHAR2
  ,p_entered_dr          	IN  OUT NOCOPY NUMBER
  ,p_entered_cr	       		IN  OUT NOCOPY NUMBER
  ,p_currency_code          	IN  OUT NOCOPY VARCHAR2
  ,p_accounted_dr		IN  OUT NOCOPY NUMBER
  ,p_accounted_cr		IN  OUT NOCOPY NUMBER
  ,p_conversion_type		IN  OUT NOCOPY VARCHAR2
  ,p_conversion_date   		IN  OUT NOCOPY DATE
  ,p_conversion_rate   		IN  OUT NOCOPY NUMBER
  ,p_party_type_code          	IN  VARCHAR2	DEFAULT NULL
  ,p_party_id          		IN  INTEGER	DEFAULT NULL
  ,p_party_site_id          	IN  INTEGER	DEFAULT NULL
  ,p_description          	IN  VARCHAR2 	DEFAULT NULL
  ,p_statistical_amount         IN  NUMBER 	DEFAULT NULL
  ,p_jgzz_recon_ref          	IN  VARCHAR2 	DEFAULT NULL
  ,p_attribute_category		IN  VARCHAR2	DEFAULT NULL
  ,p_encumbrance_type_id        IN  INTEGER 	DEFAULT NULL
  ,p_attribute1			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute2			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute3			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute4			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute5			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute6			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute7			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute8			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute9			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute10		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute11		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute12		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute13		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute14		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute15		IN  VARCHAR2	DEFAULT NULL
  ,p_ae_line_num             	OUT NOCOPY INTEGER
  ,p_creation_date		OUT NOCOPY DATE
  ,p_created_by			OUT NOCOPY INTEGER
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode			OUT NOCOPY INTEGER
  ,p_msg_mode			IN VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_info		        t_je_info;

  l_funct_curr		    VARCHAR2(15);
  l_bal_seg		        VARCHAR2(25);
  l_mgt_seg		        VARCHAR2(25);

  l_status_code		    VARCHAR2(30) := C_AE_STATUS_INCOMPLETE;
  l_gl_transfer_mode    VARCHAR2(30) := p_gl_transfer_mode;
  l_result2 		    INTEGER := 0;
  l_encumbrance_type_id	INTEGER;

  l_unrounded_entered_dr NUMBER;
  l_unrounded_entered_cr NUMBER;
  l_unrounded_accted_dr  NUMBER;
  l_unrounded_accted_cr  NUMBER;

  CURSOR c IS	SELECT	max(ae_line_num)+1
		FROM	xla_ae_lines
		WHERE	application_id = p_application_id
		AND	ae_header_id = p_ae_header_id;

  l_rounding_rule_code  VARCHAR2(30);
  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_log_module  VARCHAR2(240);

  CURSOR cur_enc IS  -- 5522973
    SELECT enabled_flag, encumbrance_type
    FROM  gl_encumbrance_types e
    WHERE e.encumbrance_type_id   = l_encumbrance_type_id;
  l_enabled   VARCHAR2(1);
  l_enc_type  VARCHAR2(30);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_journal_entry_line';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  --
  -- Validation where exception will be throw
  --
  validate_display_line_number(p_ae_header_id, NULL, p_displayed_line_number, p_application_id, p_msg_mode);
  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_ae_status_code(l_info.status_code, p_msg_mode);
  validate_code_combination_id(p_displayed_line_number, p_code_combination_id, p_msg_mode);

  get_ledger_info(l_info.ledger_id, p_application_id, p_code_combination_id, l_funct_curr, l_rounding_rule_code, l_bal_seg, l_mgt_seg);
  p_currency_code := nvl(p_currency_code, l_funct_curr);

  IF (l_gl_transfer_mode IS NULL OR l_gl_transfer_mode NOT IN ('D','S')) THEN
    get_ledger_options(p_application_id, l_info.ledger_id, l_gl_transfer_mode);
  END IF;

  IF (l_info.balance_type_code = C_JE_ACTUAL) THEN
    l_encumbrance_type_id := NULL;
  ELSIF (l_info.balance_type_code = C_JE_BUDGET) THEN
    l_encumbrance_type_id := NULL;
  ELSE
    l_encumbrance_type_id := p_encumbrance_type_id;

    IF l_encumbrance_type_id IS NULL THEN  -- 5522973
       xla_exceptions_pkg.raise_message(
         p_appli_s_name           => 'XLA'
        ,p_msg_name               => 'XLA_AP_NO_ENCUM_TYPE'
	,p_msg_mode		=> p_msg_mode);
    ELSE
       OPEN cur_enc;
       FETCH cur_enc INTO l_enabled, l_enc_type;
       IF cur_enc%NOTFOUND THEN
          CLOSE cur_enc;
          xla_exceptions_pkg.raise_message(
             p_appli_s_name         => 'XLA'
            ,p_msg_name             => 'XLA_AP_INVALID_ENCU_TYPE'
            ,p_token_1              => 'ENCUMBRANCE_TYPE_ID'
            ,p_value_1              => l_encumbrance_type_id
            ,p_msg_mode             => p_msg_mode);
       ELSIF l_enabled = 'N' THEN
          CLOSE cur_enc;
          xla_exceptions_pkg.raise_message(
             p_appli_s_name         => 'XLA'
            ,p_msg_name             => 'XLA_AP_INACTIVE_ENCUM_TYPE'
            ,p_token_1              => 'ENCUMBRANCE_TYPE_ID'
            ,p_value_1              => l_enc_type
            ,p_msg_mode             => p_msg_mode);
       END IF;
       IF cur_enc%ISOPEN THEN
          CLOSE cur_enc;
       END IF;
    END IF;

  END IF;

  --
  -- Validation where errors will be  into accounting error table
  --
  calculate_amounts
	(p_entered_dr		=> p_entered_dr
	,p_entered_cr		=> p_entered_cr
   	,p_currency_code	=> p_currency_code
	,p_functional_curr	=> l_funct_curr
	,p_rounding_rule_code   => l_rounding_rule_code
   	,p_accounted_cr		=> p_accounted_cr
    	,p_accounted_dr		=> p_accounted_dr
   	,p_unrounded_entered_cr	=> l_unrounded_entered_cr
   	,p_unrounded_entered_dr	=> l_unrounded_entered_dr
   	,p_unrounded_accted_cr	=> l_unrounded_accted_cr
   	,p_unrounded_accted_dr	=> l_unrounded_accted_dr
   	,p_conv_type		=> p_conversion_type
   	,p_conv_date		=> p_conversion_date
   	,p_conv_rate		=> p_conversion_rate);

  -- Done Validation

  IF (l_info.status_code = C_AE_STATUS_INVALID) THEN
    IF (NOT clear_errors(l_info.event_id, p_ae_header_id, p_ae_line_num)) THEN
      l_status_code := C_AE_STATUS_INVALID;
    END IF;
  END IF;

  --
  -- If the entry was a draft entry, undo draft
  --
  undo_draft_entry(l_info);

  OPEN c;
  FETCH c INTO p_ae_line_num;
  CLOSE c;

  IF (p_ae_line_num IS NULL) THEN
    p_ae_line_num := 1;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'p_ae_line_num = '||p_ae_line_num,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  --
  -- Create journal entry line
  --
  INSERT INTO xla_ae_lines
   	(ae_header_id
	,displayed_line_number
   	,ae_line_num
   	,code_combination_id
   	,gl_transfer_mode_code
   	,creation_date
   	,created_by
   	,last_update_date
   	,last_updated_by
   	,last_update_login
   	,party_type_code
   	,party_id
   	,party_site_id
   	,entered_dr
   	,entered_cr
   	,accounted_dr
   	,accounted_cr
   	,unrounded_accounted_dr
   	,unrounded_accounted_cr
   	,unrounded_entered_dr
   	,unrounded_entered_cr
	,accounting_class_code
   	,description
   	,statistical_amount
   	,currency_code
   	,currency_conversion_type
   	,currency_conversion_date
   	,currency_conversion_rate
   	,jgzz_recon_ref
   	,control_balance_flag
   	,analytical_balance_flag
	,gl_sl_link_table
     	,attribute_category
        ,encumbrance_type_id
     	,attribute1
     	,attribute2
     	,attribute3
     	,attribute4
     	,attribute5
     	,attribute6
     	,attribute7
     	,attribute8
     	,attribute9
     	,attribute10
     	,attribute11
     	,attribute12
     	,attribute13
     	,attribute14
     	,attribute15
   	,application_id
        ,gain_or_loss_flag
        ,ledger_id
        ,accounting_date
        ,mpa_accrual_entry_flag)   -- 4262811
    values
   	(p_ae_header_id
	,p_displayed_line_number
   	,p_ae_line_num
   	,p_code_combination_id
   	,l_gl_transfer_mode
     	,sysdate
     	,nvl(xla_environment_pkg.g_usr_id,-1)
     	,sysdate
     	,nvl(xla_environment_pkg.g_usr_id,-1)
     	,nvl(xla_environment_pkg.g_login_id,-1)
   	,p_party_type_code
   	,p_party_id
   	,p_party_site_id
   	,p_entered_dr
   	,p_entered_cr
   	,p_accounted_dr
   	,p_accounted_cr
   	,l_unrounded_accted_dr
   	,l_unrounded_accted_cr
   	,l_unrounded_entered_dr
   	,l_unrounded_entered_cr
	,p_accounting_class_code
   	,p_description
   	,p_statistical_amount
   	,p_currency_code
   	,p_conversion_type
   	,p_conversion_date
   	,p_conversion_rate
   	,p_jgzz_recon_ref
   	,NULL
   	,NULL
	,'XLAJEL'
     	,p_attribute_category
        ,l_encumbrance_type_id
     	,p_attribute1
     	,p_attribute2
     	,p_attribute3
     	,p_attribute4
     	,p_attribute5
     	,p_attribute6
     	,p_attribute7
     	,p_attribute8
     	,p_attribute9
     	,p_attribute10
     	,p_attribute11
     	,p_attribute12
     	,p_attribute13
     	,p_attribute14
     	,p_attribute15
   	,l_info.application_id
        ,'N'
   	,l_info.ledger_id
   	,l_info.gl_date
        ,'N')   -- 4262811 mpa_accrual_entry_flag
     RETURNING 	 creation_date
	    	,created_by
  	    	,last_update_date
	    	,last_updated_by
	    	,last_update_login
	INTO	 p_creation_date
		,p_created_by
		,p_last_update_date
		,p_last_updated_by
		,p_last_update_login;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# row inserted = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_bal_seg IS NOT NULL) THEN
    update_segment_values(p_ae_header_id, C_SEG_BALANCING, l_bal_seg, C_ACTION_ADD);
  END IF;

  IF (l_mgt_seg IS NOT NULL) THEN
    update_segment_values(p_ae_header_id, C_SEG_MANAGEMENT, l_mgt_seg, C_ACTION_ADD);
  END IF;

  create_distribution_link
    (p_application_id    => p_application_id
    ,p_ae_header_id      => p_ae_header_id
    ,p_ae_line_num       => p_ae_line_num
    ,p_temp_line_num     => p_ae_line_num
    ,p_ref_ae_header_id  => p_ae_header_id
    ,p_ref_event_id      => NULL
    ,p_ref_temp_line_num => NULL);

  IF (l_info.status_code <> l_status_code) THEN
    update	xla_ae_headers
    set		accounting_entry_status_code = l_status_code
    WHERE	ae_header_id	= p_ae_header_id
    AND		application_id	= p_application_id;
  END IF;

  p_retcode := 0;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.create_journal_entry_line');

END create_journal_entry_line;


--=============================================================================
--
-- Name: update_journal_entry_line
-- Description: Update a journal entry line.
--
--=============================================================================
PROCEDURE update_journal_entry_line
  (p_ae_header_id               IN  INTEGER
  ,p_ae_line_num             	IN  INTEGER
  ,p_displayed_line_number	IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_code_combination_id        IN  INTEGER
  ,p_gl_transfer_mode          	IN  VARCHAR2
  ,p_accounting_class_code	IN  VARCHAR2
  ,p_entered_dr          	IN  OUT NOCOPY NUMBER
  ,p_entered_cr          	IN  OUT NOCOPY NUMBER
  ,p_currency_code          	IN  OUT NOCOPY VARCHAR2
  ,p_accounted_dr		IN  OUT NOCOPY NUMBER
  ,p_accounted_cr		IN  OUT NOCOPY NUMBER
  ,p_conversion_type		IN  OUT NOCOPY VARCHAR2
  ,p_conversion_date   		IN  OUT NOCOPY DATE
  ,p_conversion_rate   		IN  OUT NOCOPY NUMBER
  ,p_party_type_code		IN  VARCHAR2	DEFAULT NULL
  ,p_party_id          		IN  INTEGER	DEFAULT NULL
  ,p_party_site_id          	IN  INTEGER	DEFAULT NULL
  ,p_description          	IN  VARCHAR2 	DEFAULT NULL
  ,p_statistical_amount         IN  NUMBER 	DEFAULT NULL
  ,p_jgzz_recon_ref          	IN  VARCHAR2 	DEFAULT NULL
  ,p_attribute_category		IN  VARCHAR2	DEFAULT NULL
  ,p_encumbrance_type_id        IN  INTEGER 	DEFAULT NULL
  ,p_attribute1			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute2			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute3			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute4			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute5			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute6			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute7			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute8			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute9			IN  VARCHAR2	DEFAULT NULL
  ,p_attribute10		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute11		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute12		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute13		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute14		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute15		IN  VARCHAR2	DEFAULT NULL
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode			OUT NOCOPY INTEGER
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_info		t_je_info;

  l_funct_curr		VARCHAR2(15);
  l_bal_seg_old		VARCHAR2(25); -- INTEGER;
  l_mgt_seg_old		VARCHAR2(25); -- INTEGER;
  l_bal_seg		VARCHAR2(25); -- INTEGER;
  l_mgt_seg		VARCHAR2(25); -- INTEGER;

  l_unrounded_entered_dr NUMBER;
  l_unrounded_entered_cr NUMBER;
  l_unrounded_accted_dr  NUMBER;
  l_unrounded_accted_cr  NUMBER;
  l_encumbrance_type_id	INTEGER;

  CURSOR c_line IS
    SELECT	code_combination_id
    FROM	xla_ae_lines
    WHERE	application_id = p_application_id
      AND       ae_header_id = p_ae_header_id
      AND	ae_line_num = p_ae_line_num;

  l_ccid_old		    INTEGER;
  l_status_code		    VARCHAR2(30);
  l_gl_transfer_mode    VARCHAR2(30);

  l_result2		        INTEGER;
  l_date		        DATE;
  l_rounding_rule_code  VARCHAR2(30);

  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_ref_ae_header_id    INTEGER;
  l_temp_line_num       INTEGER;
  l_dummy               INTEGER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_journal_entry_line';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_status_code		:= C_AE_STATUS_INCOMPLETE;
  l_gl_transfer_mode    := p_gl_transfer_mode;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  p_retcode := 0;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  IF (l_info.balance_type_code = C_JE_ACTUAL) THEN
    l_encumbrance_type_id := NULL;
  ELSIF (l_info.balance_type_code = C_JE_BUDGET) THEN
    l_encumbrance_type_id := NULL;
  ELSE
    l_encumbrance_type_id := p_encumbrance_type_id;
  END IF;

  --
  -- Validation where exception will be throw
  --
  OPEN c_line;
  FETCH c_line INTO l_ccid_old;
  CLOSE c_line;

  IF (l_ccid_old IS NULL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_LINE_NUM'
         ,p_token_1		=> 'LINE_NUM'
	 ,p_value_1		=> p_ae_line_num
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  validate_display_line_number(p_ae_header_id
                              ,p_ae_line_num
                              ,p_displayed_line_number
                              ,p_application_id
                              ,p_msg_mode);
  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_ae_status_code(l_info.status_code, p_msg_mode);

  --
  -- Validation where error will be inserted into accounting error table
  --
  get_ledger_info(l_info.ledger_id, p_application_id, p_code_combination_id, l_funct_curr, l_rounding_rule_code, l_bal_seg, l_mgt_seg);
  p_currency_code := nvl(p_currency_code, l_funct_curr);

  IF (l_gl_transfer_mode IS NULL OR l_gl_transfer_mode NOT IN ('D','S')) THEN
    get_ledger_options(p_application_id, l_info.ledger_id, l_gl_transfer_mode);
  END IF;

  calculate_amounts
	(p_entered_dr		=> p_entered_dr
	,p_entered_cr		=> p_entered_cr
   	,p_currency_code	=> p_currency_code
	,p_functional_curr	=> l_funct_curr
	,p_rounding_rule_code   => l_rounding_rule_code
   	,p_accounted_dr		=> p_accounted_dr
   	,p_accounted_cr		=> p_accounted_cr
   	,p_unrounded_entered_cr	=> l_unrounded_entered_cr
   	,p_unrounded_entered_dr	=> l_unrounded_entered_dr
   	,p_unrounded_accted_cr	=> l_unrounded_accted_cr
   	,p_unrounded_accted_dr	=> l_unrounded_accted_dr
   	,p_conv_type		=> p_conversion_type
   	,p_conv_date		=> p_conversion_date
   	,p_conv_rate		=> p_conversion_rate);

  -- Done Validation

  IF (l_info.status_code = C_AE_STATUS_INVALID) THEN
    IF (NOT clear_errors(l_info.event_id, p_ae_header_id, p_ae_line_num)) THEN
      l_status_code := C_AE_STATUS_INVALID;
    END IF;
  END IF;

  --
  -- If the entry was a draft entry, undo draft
  --
  undo_draft_entry(l_info);

  --
  -- For the case reversed entries are updated
  --
  -- For reversal entries:
  --   ref_ae_header id <> p_ae_header_id
  --   temp_line_num = -1 * p_ae_line_num
  --
  -- For Non-reversal entries:
  --   ref_ae_header_id = p_ae_header_id
  --   temp_line_num = p_ae_line_num
  --
  l_temp_line_num := p_ae_line_num;

  get_rev_line_info
    (p_application_id   => p_application_id
    ,p_ae_header_id     => p_ae_header_id
    ,p_temp_line_num    => l_temp_line_num
    ,p_ref_ae_header_id => l_ref_ae_header_id
    ,p_ref_event_id     => l_dummy);

  update_distribution_link
    (p_application_id           => p_application_id
    ,p_ae_header_id             => p_ae_header_id
    ,p_ref_ae_header_id         => l_ref_ae_header_id
    ,p_temp_line_num            => l_temp_line_num
    ,p_unrounded_entered_dr     => l_unrounded_entered_dr
    ,p_unrounded_entered_cr     => l_unrounded_entered_cr
    ,p_unrounded_accounted_dr   => l_unrounded_accted_dr
    ,p_undournde_accounted_cr   => l_unrounded_accted_cr
    ,p_statistical_amount       => p_statistical_amount);

  --
  -- Update journal entry line with modified information
  --
  UPDATE xla_ae_lines
    SET	 code_combination_id	= p_code_combination_id
	,displayed_line_number 	= p_displayed_line_number
      	,gl_transfer_mode_code	= l_gl_transfer_mode
   	,party_id		= p_party_id
   	,party_site_id		= p_party_site_id
   	,party_type_code	= p_party_type_code
   	,entered_dr		= p_entered_dr
   	,entered_cr		= p_entered_cr
   	,unrounded_entered_dr	= l_unrounded_entered_dr
   	,unrounded_entered_cr	= l_unrounded_entered_cr
   	,accounted_dr		= p_accounted_dr
   	,accounted_cr		= p_accounted_cr
   	,unrounded_accounted_dr	= l_unrounded_accted_dr
   	,unrounded_accounted_cr	= l_unrounded_accted_cr
   	,description		= p_description
 	,accounting_class_code	= p_accounting_class_code
   	,statistical_amount	= p_statistical_amount
	,currency_code		= p_currency_code
   	,currency_conversion_type = p_conversion_type
   	,currency_conversion_date = p_conversion_date
   	,currency_conversion_rate = p_conversion_rate
   	,jgzz_recon_ref 	= p_jgzz_recon_ref
	,attribute_category	= p_attribute_category
        ,encumbrance_type_id = l_encumbrance_type_id
	,attribute1		= p_attribute1
	,attribute2		= p_attribute2
	,attribute3		= p_attribute3
	,attribute4		= p_attribute4
	,attribute5		= p_attribute5
	,attribute6		= p_attribute6
	,attribute7		= p_attribute7
	,attribute8		= p_attribute8
	,attribute9		= p_attribute9
	,attribute10		= p_attribute10
	,attribute11		= p_attribute11
	,attribute12		= p_attribute12
	,attribute13		= p_attribute13
	,attribute14		= p_attribute14
	,attribute15		= p_attribute15
	,ledger_id	        = l_info.ledger_id
	,accounting_date	= l_info.gl_date
   	,last_update_date	= sysdate
   	,last_updated_by	= nvl(xla_environment_pkg.g_usr_id,-1)
   	,last_update_login	= nvl(xla_environment_pkg.g_login_id,-1)
    WHERE	ae_header_id	= p_ae_header_id
      AND	ae_line_num	= p_ae_line_num
      AND	application_id	= p_application_id
     RETURNING 	 last_update_date
	    	,last_updated_by
	    	,last_update_login
	INTO	 p_last_update_date
		,p_last_updated_by
		,p_last_update_login;

  IF (l_ccid_old <> p_code_combination_id) THEN
    get_ledger_info(l_info.ledger_id, p_application_id, p_code_combination_id, l_funct_curr, l_rounding_rule_code, l_bal_seg_old, l_mgt_seg_old);

    IF (l_bal_seg IS NULL) THEN
      update_segment_values(p_ae_header_id, C_SEG_BALANCING, l_bal_seg_old, C_ACTION_DEL);
    ELSIF (l_bal_seg <> l_bal_seg_old) THEN
      update_segment_values(p_ae_header_id, C_SEG_BALANCING, l_bal_seg_old, C_ACTION_DEL);
      update_segment_values(p_ae_header_id, C_SEG_BALANCING, l_bal_seg, C_ACTION_ADD);
    END IF;

    IF (l_mgt_seg IS NULL) THEN
      update_segment_values(p_ae_header_id, C_SEG_MANAGEMENT, l_mgt_seg_old, C_ACTION_DEL);
    ELSIF (l_mgt_seg <> l_mgt_seg_old) THEN
      update_segment_values(p_ae_header_id, C_SEG_MANAGEMENT, l_mgt_seg_old, C_ACTION_DEL);
      update_segment_values(p_ae_header_id, C_SEG_MANAGEMENT, l_mgt_seg, C_ACTION_ADD);
    END IF;
  END IF;

  IF (l_info.status_code <> l_status_code) THEN
    UPDATE xla_ae_headers
      set 	accounting_entry_status_code 	= l_status_code
      WHERE	ae_header_id	= p_ae_header_id
        AND	application_id	= l_info.application_id;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_line%ISOPEN) THEN
    CLOSE c_line;
  END IF;
  RAISE;
WHEN OTHERS                                   THEN
  IF (c_line%ISOPEN) THEN
    CLOSE c_line;
  END IF;
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.update_journal_entry_line');

END update_journal_entry_line;


--=============================================================================
--
-- Name: delete_journal_entry_line
-- Description: Delete a journal entry line.
--
--=============================================================================
PROCEDURE delete_journal_entry_line
  (p_ae_header_id               IN  INTEGER
  ,p_ae_line_num             	IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS

  l_info                t_je_info;
  l_bal_seg             INTEGER;
  l_mgt_seg             INTEGER;
  l_status_code	        VARCHAR2(30) := C_AE_STATUS_INCOMPLETE;
  l_event_source_info	xla_events_pub_pkg.t_event_source_info;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_journal_entry_line';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);

  --
  -- Validation where exception will be throw
  --
  validate_line_number(p_ae_header_id, p_ae_line_num, p_application_id, p_msg_mode);
  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_ae_status_code(l_info.status_code, p_msg_mode);
  -- Done validation

  --
  -- If the entry was a draft entry, undo draft
  --
  undo_draft_entry(l_info);

  IF (l_info.status_code <> l_status_code) THEN
    UPDATE xla_ae_headers
      set 	accounting_entry_status_code 	= l_status_code
      WHERE	ae_header_id	= p_ae_header_id
      AND	application_id	= p_application_id;
  END IF;

  IF (NOT xla_analytical_criteria_pkg.single_update_detail_value
	(p_application_id		=> p_application_id
	,p_ae_header_id			=> p_ae_header_id
	,p_ae_line_num			=> p_ae_line_num
	,p_analytical_detail_value_id	=> NULL
	,p_anacri_code			=> NULL
	,p_anacri_type_code		=> NULL
	,p_amb_context_code		=> NULL
	,p_update_mode			=> 'D')) THEN
    ROLLBACK to SAVEPOINT DELETE_JOURNAL_ENTRY;

    xla_exceptions_pkg.raise_message
         (p_appli_s_name        => 'XLA'
         ,p_msg_name            => 'XLA_COMMON_INTERNAL_ERROR'
         ,p_token_1            	=> 'MESSAGE'
         ,p_value_1            	=> 'Error in xla_analytical_criteria_pkg.single_update_detail_value'
         ,p_token_2            	=> 'LOCATION'
         ,p_value_2            	=> 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entry'
         ,p_msg_mode            => p_msg_mode);
  END IF;

  delete_distribution_link
    (p_application_id           => p_application_id
    ,p_ae_header_id             => p_ae_header_id
    ,p_ref_ae_header_id         => p_ae_header_id
    ,p_temp_line_num            => p_ae_line_num);

  DELETE xla_ae_lines
	WHERE ae_header_id = p_ae_header_id
	  AND ae_line_num = p_ae_line_num
	  AND application_id = p_application_id;

  update_segment_values(p_ae_header_id, C_SEG_BALANCING, l_bal_seg, C_ACTION_DEL);
  update_segment_values(p_ae_header_id, C_SEG_MANAGEMENT, l_mgt_seg, C_ACTION_DEL);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_journal_entry_line',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.delete_journal_entry_line');

END delete_journal_entry_line;


--=============================================================================
--
-- Name: complete_journal_entry
-- Description: Complete a journal entry.
--
--=============================================================================
PROCEDURE complete_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr            IN  VARCHAR2
  ,p_je_source_name             IN  VARCHAR2
  ,p_ae_status_code             OUT NOCOPY VARCHAR2
  ,p_funds_status_code          OUT NOCOPY VARCHAR2
  ,p_completion_seq_value       OUT NOCOPY VARCHAR2
  ,p_completion_seq_ver_id      OUT NOCOPY INTEGER
  ,p_completed_date             OUT NOCOPY DATE
  ,p_gl_transfer_status_code    OUT NOCOPY VARCHAR2
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_transfer_request_id	OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY VARCHAR2
  ,p_msg_mode                   IN  VARCHAR2    DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.complete_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  complete_journal_entry
        (p_ae_header_id                 => p_ae_header_id
        ,p_application_id               => p_application_id
        ,p_completion_option            => p_completion_option
        ,p_functional_curr              => p_functional_curr
        ,p_je_source_name               => p_je_source_name
        ,p_ae_status_code               => p_ae_status_code
        ,p_funds_status_code            => p_funds_status_code
        ,p_completion_seq_value         => p_completion_seq_value
        ,p_completion_seq_ver_id        => p_completion_seq_ver_id
        ,p_completed_date               => p_completed_date
        ,p_gl_transfer_status_code      => p_gl_transfer_status_code
        ,p_last_update_date             => p_last_update_date
        ,p_last_updated_by              => p_last_updated_by
        ,p_last_update_login            => p_last_update_login
        ,p_transfer_request_id          => p_transfer_request_id
        ,p_retcode                      => p_retcode
        ,p_rev_flag                     => 'N'
        ,p_rev_method                   => 'N'
        ,p_rev_orig_event_id            => -1
        ,p_msg_mode                     => p_msg_mode);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.complete_journal_entry');

END complete_journal_entry;

--=============================================================================
--
-- Name: complete_journal_entry
-- Description: Complete a journal entry.
--
--=============================================================================
PROCEDURE complete_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr            IN  VARCHAR2
  ,p_je_source_name             IN  VARCHAR2
  ,p_ae_status_code             OUT NOCOPY VARCHAR2
  ,p_funds_status_code          OUT NOCOPY VARCHAR2
  ,p_completion_seq_value       OUT NOCOPY VARCHAR2
  ,p_completion_seq_ver_id      OUT NOCOPY INTEGER
  ,p_completed_date             OUT NOCOPY DATE
  ,p_gl_transfer_status_code    OUT NOCOPY VARCHAR2
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_transfer_request_id        OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY VARCHAR2
  ,p_msg_mode                   IN  VARCHAR2    DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_flag                   IN  VARCHAR2 DEFAULT 'N'
  ,p_rev_method                 IN  VARCHAR2 DEFAULT 'N'
  ,p_rev_orig_event_id          IN  NUMBER DEFAULT -1)
IS

  l_info                t_je_info;
  l_ae_header_ids       xla_je_validation_pkg.t_array_int;
  l_ledger_ids          xla_je_validation_pkg.t_array_int;
  l_status_codes        xla_je_validation_pkg.t_array_varchar;
  l_seq_values          t_array_int;
  l_seq_version_ids     t_array_int;
  l_seq_assign_ids      t_array_int;
  l_orig_status_code    VARCHAR2(30);
  l_bal_update_mode     VARCHAR2(30) := NULL;
  l_result              INTEGER := 0;
  l_status_code         VARCHAR2(3) := NULL;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.complete_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  p_retcode := C_COMPLETION_SUCCESS;

  reorder_line_number
  	(p_application_id	=> p_application_id
  	,p_ae_header_id		=> p_ae_header_id);

  -----------------------------------------------------------------------------
  -- Validation
  --
  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);
  l_orig_status_code  := l_info.status_code;
  l_ledger_ids(1)     := l_info.ledger_id;
  l_ae_header_ids(1)  := p_ae_header_id;

  IF (l_orig_status_code = C_AE_STATUS_INVALID) THEN
    DELETE FROM xla_ae_lines
          WHERE application_id = p_application_id
            AND ae_header_id   = p_ae_header_id
            AND accounting_class_code IN ('ROUNDING', 'BALANCE', 'INTRA', 'INTER');

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => '# balancing line deleted = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;
  END IF;

  xla_accounting_err_pkg.initialize
       (p_application_id          => p_application_id);

  validate_ae_type_code(l_info.type_code, p_msg_mode);
  validate_ae_status_code(l_orig_status_code, p_msg_mode);

  l_result := validate_completion_action
	(p_entity_id		=> l_info.entity_id
	,p_event_id		=> l_info.event_id
	,p_ledger_id		=> l_info.ledger_id
	,p_ae_header_id		=> p_ae_header_id
   	,p_completion_option 	=> p_completion_option);

  l_result := l_result + validate_description
  	(p_entity_id		=> l_info.entity_id
  	,p_event_id		=> l_info.event_id
  	,p_ledger_id		=> l_info.ledger_id
  	,p_ae_header_id		=> p_ae_header_id
  	,p_description  	=> l_info.description);

  l_result := l_result + validate_legal_entity_id
  	(p_entity_id		=> l_info.entity_id
  	,p_event_id		=> l_info.event_id
  	,p_ledger_id		=> l_info.ledger_id
  	,p_ae_header_id		=> p_ae_header_id
  	,p_legal_entity_id  	=> l_info.legal_entity_id);

  l_result := l_result + validate_line_counts
  	(p_entity_id		=> l_info.entity_id
  	,p_event_id		=> l_info.event_id
  	,p_ledger_id		=> l_info.ledger_id
  	,p_ae_header_id		=> p_ae_header_id
  	,p_application_id  	=> p_application_id
        ,p_balance_type_code    => l_info.balance_type_code);

  l_result := l_result + validate_amounts
	(p_entity_id		=> l_info.entity_id
   	,p_event_id		=> l_info.event_id
	,p_ledger_id		=> l_info.ledger_id
	,p_ae_header_id		=> p_ae_header_id
	,p_application_id	=> p_application_id
  	,p_functional_curr	=> p_functional_curr);
  -----------------------------------------------------------------------------
  -- Determine the status code of the journal entry
  --
  IF (l_result > 0) THEN
    p_retcode := C_COMPLETION_FAILED;
    l_status_codes(1) := C_AE_STATUS_INVALID;
  ELSIF (p_completion_option = C_COMPLETION_OPTION_DRAFT) THEN
    l_status_codes(1) := C_AE_STATUS_DRAFT;
  ELSE
    l_status_codes(1) := C_AE_STATUS_FINAL;
    p_completed_date := sysdate;
  END IF;

  -----------------------------------------------------------------------------
  -- Delete previously created entry for alternative currency ledger
  -- and re-create.  Does not apply to Budget entries.
  --
  IF (l_info.balance_type_code <> 'B') THEN

    delete_mrc_entries
                   (p_event_id             => l_info.event_id
                   ,p_application_id       => l_info.application_id
                   ,p_ledger_id            => l_info.ledger_id);

    IF (p_retcode = C_COMPLETION_SUCCESS) THEN
      IF(p_rev_flag = 'Y') THEN
        create_mrc_reversal_entry
                      (p_info                => l_info
                      ,p_reversal_method     => p_rev_method
                      ,p_orig_event_id       => p_rev_orig_event_id
                      ,p_ledger_ids          => l_ledger_ids
                      ,p_rev_ae_header_ids   => l_ae_header_ids
                      ,p_rev_status_codes    => l_status_codes);
      ELSE
        p_retcode := create_mrc_entries
                      (p_info            => l_info
                      ,p_je_source_name  => p_je_source_name
                      ,p_ledger_ids      => l_ledger_ids
                      ,p_ae_header_ids   => l_ae_header_ids
                      ,p_status_codes    => l_status_codes);
      END IF;
    END IF;
  END IF;

  -----------------------------------------------------------------------------
  -- Perform more validation and balance entries
  l_result := xla_je_validation_pkg.balance_manual_entry
	(p_application_id	=> l_info.application_id
        ,p_balance_flag         => CASE WHEN p_retcode = C_COMPLETION_SUCCESS
                                        THEN TRUE
                                        ELSE FALSE END
        ,p_ledger_ids           => l_ledger_ids
        ,p_end_date             => l_info.gl_date      -- 4262811
        ,p_ae_header_ids        => l_ae_header_ids
        ,p_status_codes         => l_status_codes
        ,p_accounting_mode      => CASE WHEN p_completion_option = C_COMPLETION_OPTION_DRAFT
                                        THEN 'D'
                                        ELSE 'F' END);

  IF (l_result > 0) THEN
    p_retcode := C_COMPLETION_FAILED;
  END IF;

  SAVEPOINT BEFORE_RESERVE_FUNDS;

  -----------------------------------------------------------------------------
  -- Reserve funds
  IF (p_retcode = C_COMPLETION_SUCCESS AND
      p_completion_option <> C_COMPLETION_OPTION_DRAFT) THEN
    p_retcode := reserve_funds(p_info     => l_info
                              ,p_msg_mode => p_msg_mode);
    IF (p_retcode = C_COMPLETION_FAILED) THEN
      l_status_codes(1) := C_AE_STATUS_INVALID;
    END IF;
  END IF;

  -----------------------------------------------------------------------------
  -- Populate sequence numbers
  --
  IF (p_retcode = C_COMPLETION_SUCCESS AND
      p_completion_option <> C_COMPLETION_OPTION_DRAFT) THEN
    p_retcode := populate_sequence_numbers
                        (p_info                 => l_info
                        ,p_je_source_name       => p_je_source_name
                        ,p_completed_date       => p_completed_date
                        ,p_ledger_ids           => l_ledger_ids
                        ,p_ae_header_ids        => l_ae_header_ids
                        ,p_status_codes         => l_status_codes
                        ,p_seq_version_ids      => l_seq_version_ids
                        ,p_seq_values           => l_seq_values
                        ,p_seq_assign_ids       => l_seq_assign_ids);

  END IF;

  IF (p_retcode = C_COMPLETION_FAILED) THEN
    ROLLBACK TO SAVEPOINT BEFORE_RESERVE_FUNDS;
  END IF;

  IF (p_retcode = C_COMPLETION_FAILED OR
      p_completion_option = C_COMPLETION_OPTION_DRAFT) THEN
    FOR i IN 1..l_ae_header_ids.COUNT LOOP
      l_seq_values(i)       := -1;
      l_seq_version_ids(i)  := -1;
      l_seq_assign_ids(i)   := -1;
    END LOOP;
  END IF;

  --
  -- Clear the error table for the journal entry
  --
  DELETE FROM xla_accounting_errors WHERE event_id = l_info.event_id;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'p_retcode = '||p_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (p_retcode = C_COMPLETION_SUCCESS) THEN
    p_funds_status_code := l_info.funds_status_code;
    p_completion_seq_value := l_seq_values(1);
    p_completion_seq_ver_id := l_seq_version_ids(1);
    p_ae_status_code := l_status_codes(1);
  ELSE
    p_completed_date := NULL;
    p_funds_status_code := NULL;

    FOR i IN 1 .. l_ae_header_ids.COUNT LOOP
      IF (l_status_codes(i) <> C_AE_STATUS_INVALID) THEN
        l_status_codes(i) := C_AE_STATUS_RELATED;
        xla_accounting_err_pkg.build_message(
             p_appli_s_name         => 'XLA'
            ,p_msg_name             => 'XLA_AP_RELATED_INVALID_JE'
            ,p_entity_id            => l_info.entity_id
            ,p_event_id             => l_info.event_id
            ,p_ledger_id            => l_ledger_ids(i)
            ,p_ae_header_id         => l_ae_header_ids(i)
            ,p_ae_line_num          => NULL
            ,p_accounting_batch_id  => NULL);
      END IF;
    END LOOP;

    xla_accounting_err_pkg.insert_errors;
  END IF;

  p_last_update_date  := sysdate;
  p_last_updated_by   := nvl(xla_environment_pkg.g_usr_id,-1);
  p_last_update_login := nvl(xla_environment_pkg.g_login_id,-1);
  IF (l_info.type_code = C_TYPE_UPGRADE) THEN
    p_gl_transfer_status_code := C_GL_TRANSFER_MODE_SELECTED;
  ELSE
    p_gl_transfer_status_code := C_GL_TRANSFER_MODE_NO;
  END IF;

  --
  -- Update journal entry header
  --
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'Update header entry headers',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);

    FOR i IN 1 .. l_ae_header_ids.COUNT LOOP
      trace(p_msg    => 'ae_header_id = '||l_ae_header_ids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'status_code = '||l_status_codes(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'seq_value = '||l_seq_values(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'seq_version_id = '||l_seq_version_ids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'seq_assign_id = '||l_seq_assign_ids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END LOOP;
  END IF;


  FORALL i IN 1 .. l_ae_header_ids.COUNT
    UPDATE xla_ae_headers
       SET accounting_entry_status_code   = l_status_codes(i)
          ,funds_status_code              = p_funds_status_code
 	  ,completion_acct_seq_value      = DECODE(l_seq_values(i),-1,NULL,l_seq_values(i))
 	  ,completion_acct_seq_version_id = DECODE(l_seq_version_ids(i),-1,NULL,l_seq_version_ids(i))
	  ,completion_acct_seq_assign_id  = DECODE(l_seq_assign_ids(i),-1,NULL,l_seq_assign_ids(i))
	  ,completed_date                 = p_completed_date
	  ,packet_id                      = l_info.packet_id
	  ,gl_transfer_status_code        = p_gl_transfer_status_code
          ,last_update_date               = p_last_update_date
          ,last_updated_by                = p_last_updated_by
          ,last_update_login              = p_last_update_login
     WHERE ae_header_id                   = l_ae_header_ids(i)
       AND application_id                 = p_application_id;


  -- Fix bug 5074662 - populate gl_sl_link_id if JE is completed in Final mode
  IF ((p_completion_option = C_COMPLETION_OPTION_FINAL) OR
      (p_completion_option = C_COMPLETION_OPTION_POST)) THEN
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'p_completion_option = FINAL - Update gl_sl_link_id',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;



    FORALL i IN 1 .. l_ae_header_ids.COUNT
      UPDATE xla_ae_lines
         SET gl_sl_link_id                = XLA_GL_SL_LINK_ID_S.nextval
            ,last_update_date             = p_last_update_date
            ,last_updated_by              = p_last_updated_by
            ,last_update_login            = p_last_update_login
       WHERE ae_header_id                 = l_ae_header_ids(i)
         AND application_id               = p_application_id
	 AND gl_sl_link_id    IS NULL;
  END IF;

  --
  -- Call balancing routine
  --
  IF (p_retcode = C_COMPLETION_FAILED) THEN
    l_bal_update_mode := C_BALANCE_DELETE;
  ELSIF (l_orig_status_code = C_AE_STATUS_DRAFT AND
         p_completion_option = C_COMPLETION_OPTION_FINAL) THEN
    l_bal_update_mode := C_BALANCE_D_TO_F;
  ELSIF (l_orig_status_code <> C_AE_STATUS_DRAFT or
	 p_completion_option <> C_COMPLETION_OPTION_DRAFT) THEN
    l_bal_update_mode := C_BALANCE_ADD;
  ELSE
    l_bal_update_mode := NULL;
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'l_bal_update_mode:'||l_bal_update_mode,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;



  IF (l_bal_update_mode IS NOT NULL) THEN
    --FORALL i IN 1 .. l_ae_header_ids.COUNT
      UPDATE xla_ae_lines l
         SET control_balance_flag =
                  (SELECT DECODE(l.accounting_class_code,
                                 'INTER', NULL,
                                 'INTRA', NULL,
                                 DECODE(NVL(ccid.reference3,'N'),'N',NULL, 'R', NULL,
                                        DECODE(ccid.account_type, 'A', 'P'
                                                                , 'L', 'P'
                                                                , 'O', 'P'
                                                                , NULL)))
                     FROM gl_code_combinations   ccid
                    WHERE ccid.code_combination_id = l.code_combination_id)
            ,analytical_balance_flag =
                  (SELECT DECODE(count(1),0,NULL,'P')
                     FROM xla_ae_line_acs ac
                    WHERE ac.ae_header_id(+) = l.ae_header_id
                      AND ac.ae_line_num(+)  = l.ae_line_num)
            ,last_update_date                 = p_last_update_date
            ,last_updated_by                  = p_last_updated_by
            ,last_update_login                = p_last_update_login
       WHERE l.application_id = p_application_id
         AND l.ae_header_id  = p_ae_header_id;

	IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		IF (NOT xla_balances_pkg.massive_update
				(p_application_id 	=> l_info.application_id
				,p_ledger_id		=> NULL
				,p_entity_id		=> l_info.entity_id
				,p_event_id		=> NULL
				,p_request_id		=> NULL
				,p_accounting_batch_id	=> NULL
				,p_update_mode		=> l_bal_update_mode
				,p_execution_mode	=> C_BALANCE_ONLINE)) THEN

		  xla_exceptions_pkg.raise_message
			  (p_appli_s_name	=> 'XLA'
			  ,p_msg_name		=> 'XLA_INTERNAL_ERROR'
			  ,p_token_1            => 'MESSAGE'
			  ,p_value_1            => 'Error in balance calculation'
			  ,p_token_2            => 'LOCATION'
			  ,p_value_2            => 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entries'
		  ,p_msg_mode		=> xla_exceptions_pkg.C_STANDARD_MESSAGE);
		END IF;
	ELSE
		IF (NOT xla_balances_calc_pkg.massive_update
	  		(p_application_id 	=> l_info.application_id
	  		,p_ledger_id		=> NULL
			,p_entity_id		=> l_info.entity_id
   	  		,p_event_id		=> NULL
			,p_request_id		=> NULL
	  		,p_accounting_batch_id	=> NULL
   	  		,p_update_mode		=> l_bal_update_mode
	  		,p_execution_mode	=> C_BALANCE_ONLINE)) THEN

      xla_exceptions_pkg.raise_message
          (p_appli_s_name	=> 'XLA'
          ,p_msg_name		=> 'XLA_INTERNAL_ERROR'
          ,p_token_1            => 'MESSAGE'
          ,p_value_1            => 'Error in balance calculation'
          ,p_token_2            => 'LOCATION'
          ,p_value_2            => 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entries'
	  ,p_msg_mode		=> xla_exceptions_pkg.C_STANDARD_MESSAGE);
    END IF;

	END IF;
  END IF;

  IF (p_retcode = C_COMPLETION_SUCCESS) THEN

    --
    -- Update event status to 'Processed'
    --

 /* Bug 7011889 - Call the update event status only if Reversal event id is not NULL and if it
                  is not already updated */

 IF g_rev_event_id IS NOT NULL THEN

    SELECT event_status_code
    INTO l_status_code
    FROM xla_events
    WHERE event_id = g_rev_event_id
    AND application_id = p_application_id;

    IF l_status_code <>'P' THEN

       update_event_status
           (p_info                  => l_info
           ,p_completion_option     => p_completion_option);
    ELSE
       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'Event id is already processed',
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
       END IF;
    END IF;

 ELSIF g_rev_event_id IS NULL THEN
 /*
  bug#8545129 for manual events created from UI there is no reversal event id
  This else is considered to update the status of the manual events created
  from UI. If not updated the events remain in U even if they are finally accounted
  and customer is not able to close their periods as these events appear in
  period close report.
 */
 -- in case of manual events getting created from UI
      update_event_status
           (p_info                  => l_info
           ,p_completion_option     => p_completion_option);

 END IF;

    --
    -- Transfer to GL
    --
   transfer_to_gl
           (p_info                  => l_info
           ,p_application_id        => p_application_id
           ,p_completion_option     => p_completion_option
           ,p_transfer_request_id   => p_transfer_request_id);


  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure complete_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;
WHEN OTHERS THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.complete_journal_entry');

END complete_journal_entry;


--===============================================================================
-- Overloading Reverse Journal Entry with INTEGER for regular calls without array
-- Changed as part of Encumbarance DFIX API
--===============================================================================
--=============================================================================
--
-- Name: reverse_journal_entry
-- Description: Reverse a journal entry.
-- Bug 7011889 - Modified to handle array of header ids instead of variable
--=============================================================================

/* Bug 7011889 - Modified to handle array of header ids instead of variable */


PROCEDURE reverse_journal_entry
  (p_array_je_header_id         IN  xla_je_validation_pkg.t_array_int
  ,p_application_id		IN  INTEGER
  ,p_reversal_method            IN  VARCHAR2
  ,p_gl_date                    IN  DATE
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr		IN  VARCHAR2
  ,p_je_source_name		IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_header_id		OUT NOCOPY INTEGER
  ,p_rev_event_id		OUT NOCOPY INTEGER
  ,p_completion_retcode         OUT NOCOPY VARCHAR2
  ,p_transfer_request_id	OUT NOCOPY INTEGER)
IS
  l_info		t_je_info;
  l_period_name		VARCHAR2(30);
  l_result		INTEGER;

  l_ae_status_code             VARCHAR2(30);
  l_funds_status_code          VARCHAR2(30);
  l_completion_seq_value       VARCHAR2(240);
  l_completion_seq_ver_id      INTEGER;
  l_completed_date             DATE;
  l_gl_transfer_status_code    VARCHAR2(30);

  l_last_update_date	DATE;
  l_last_updated_by	INTEGER;
  l_last_update_login	INTEGER;
  v_array_header_id     INTEGER;

  l_log_module          VARCHAR2(240);
BEGIN

/* Bug 7011889 - Assigning global variables to NULL */
  g_rev_event_id  :=  NULL;
  g_entity_id     :=  NULL;

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reverse_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reverse_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  fnd_msg_pub.initialize;
  --
  -- Validation
  --

 /* Bug 7011889 - Looping through for all header ids selected for an event for reversal */

  FOR i in p_array_je_header_id.FIRST..p_array_je_header_id.LAST
  LOOP
  l_info := get_header_info(p_array_je_header_id(i),p_application_id, p_msg_mode);
  validate_ae_type_code(l_info.type_code, p_msg_mode);

  l_result := validate_reversal_method
	(p_entity_id		=> l_info.entity_id
	,p_event_id		=> l_info.event_id
	,p_ledger_id		=> l_info.ledger_id
   	,p_ae_header_id		=> p_array_je_header_id(i) --p_ae_header_id
   	,p_reversal_method	=> p_reversal_method);

  IF (p_completion_option NOT in (C_COMPLETION_OPTION_DRAFT,
				  C_COMPLETION_OPTION_FINAL,
			          C_COMPLETION_OPTION_TRANSFER,
			          C_COMPLETION_OPTION_POST)) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_COMP_OPTION'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (l_info.status_code <> C_AE_STATUS_FINAL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_NO_REV_NON_FINAL'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  -- Done validation

  --
  -- Create reversal journal entry
  --
  create_reversal_entry
  	(p_info			=> l_info
  	,p_reversal_method	=> p_reversal_method
	,p_gl_date		=> p_gl_date
	,p_msg_mode		=> p_msg_mode
	,p_rev_header_id	=> p_rev_header_id
	,p_rev_event_id		=> p_rev_event_id);

  --
  -- Complete journal entry if requested
  --

  IF (p_completion_option <> C_COMPLETION_OPTION_SAVE) THEN
    complete_journal_entry
	(p_ae_header_id			=> p_rev_header_id
	,p_application_id		=> l_info.application_id
	,p_completion_option		=> p_completion_option
  	,p_functional_curr		=> p_functional_curr
  	,p_je_source_name		=> p_je_source_name
  	,p_ae_status_code		=> l_ae_status_code
  	,p_funds_status_code		=> l_funds_status_code
  	,p_completion_seq_value		=> l_completion_seq_value
  	,p_completion_seq_ver_id	=> l_completion_seq_ver_id
  	,p_completed_date		=> l_completed_date
  	,p_gl_transfer_status_code	=> l_gl_transfer_status_code
	,p_last_update_date		=> l_last_update_date
	,p_last_updated_by		=> l_last_updated_by
	,p_last_update_login		=> l_last_update_login
	,p_transfer_request_id		=> p_transfer_request_id
  	,p_retcode 			=> p_completion_retcode
        ,p_rev_flag                     => 'Y'
        ,p_rev_method                   => p_reversal_method
        ,p_rev_orig_event_id            => l_info.event_id
        ,p_msg_mode                     => p_msg_mode);
  END IF;
  END LOOP;

  /* Bug 7011889 - End of loop for all header ids selected for an event for reversal */

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reverse_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.reverse_journal_entry');

END reverse_journal_entry;



--=============================================================================
--
-- Name: reverse_journal_entry
-- Description: Reverse a journal entry.
--
--=============================================================================

PROCEDURE reverse_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_reversal_method            IN  VARCHAR2
  ,p_gl_date                    IN  DATE
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr		IN  VARCHAR2
  ,p_je_source_name		IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_header_id		OUT NOCOPY INTEGER
  ,p_rev_event_id		OUT NOCOPY INTEGER
  ,p_completion_retcode         OUT NOCOPY VARCHAR2
  ,p_transfer_request_id	OUT NOCOPY INTEGER)
IS
  l_info		t_je_info;
  l_period_name		VARCHAR2(30);
  l_result		INTEGER;

  l_ae_status_code             VARCHAR2(30);
  l_funds_status_code          VARCHAR2(30);
  l_completion_seq_value       VARCHAR2(240);
  l_completion_seq_ver_id      INTEGER;
  l_completed_date             DATE;
  l_gl_transfer_status_code    VARCHAR2(30);

  l_last_update_date	DATE;
  l_last_updated_by	INTEGER;
  l_last_update_login	INTEGER;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reverse_journal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reverse_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  fnd_msg_pub.initialize;
  --
  -- Validation
  --
  l_info := get_header_info(p_ae_header_id, p_application_id, p_msg_mode);
  validate_ae_type_code(l_info.type_code, p_msg_mode);

  l_result := validate_reversal_method
	(p_entity_id		=> l_info.entity_id
	,p_event_id		=> l_info.event_id
	,p_ledger_id		=> l_info.ledger_id
   	,p_ae_header_id		=> p_ae_header_id
   	,p_reversal_method	=> p_reversal_method);

  IF (p_completion_option NOT in (C_COMPLETION_OPTION_DRAFT,
				  C_COMPLETION_OPTION_FINAL,
			          C_COMPLETION_OPTION_TRANSFER,
			          C_COMPLETION_OPTION_POST)) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_COMP_OPTION'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (l_info.status_code <> C_AE_STATUS_FINAL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_NO_REV_NON_FINAL'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  -- Done validation

  --
  -- Create reversal journal entry
  --
  create_reversal_entry
  	(p_info			=> l_info
  	,p_reversal_method	=> p_reversal_method
	,p_gl_date		=> p_gl_date
	,p_msg_mode		=> p_msg_mode
	,p_rev_header_id	=> p_rev_header_id
	,p_rev_event_id		=> p_rev_event_id);

  --
  -- Complete journal entry if requested
  --
  IF (p_completion_option <> C_COMPLETION_OPTION_SAVE) THEN
    complete_journal_entry
	(p_ae_header_id			=> p_rev_header_id
	,p_application_id		=> l_info.application_id
	,p_completion_option		=> p_completion_option
  	,p_functional_curr		=> p_functional_curr
  	,p_je_source_name		=> p_je_source_name
  	,p_ae_status_code		=> l_ae_status_code
  	,p_funds_status_code		=> l_funds_status_code
  	,p_completion_seq_value		=> l_completion_seq_value
  	,p_completion_seq_ver_id	=> l_completion_seq_ver_id
  	,p_completed_date		=> l_completed_date
  	,p_gl_transfer_status_code	=> l_gl_transfer_status_code
	,p_last_update_date		=> l_last_update_date
	,p_last_updated_by		=> l_last_updated_by
	,p_last_update_login		=> l_last_update_login
	,p_transfer_request_id		=> p_transfer_request_id
  	,p_retcode 			=> p_completion_retcode
        ,p_rev_flag                     => 'Y'
        ,p_rev_method                   => p_reversal_method
        ,p_rev_orig_event_id            => l_info.event_id
        ,p_msg_mode                     => p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reverse_journal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.reverse_journal_entry');

END reverse_journal_entry;









--=============================================================================
--
--
--
--
--
--
--          *********** private procedures and functions **********
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
-- Name: get_header_info
-- Description: Retrieve header information.
-- Return: t_je_info
--
--=============================================================================
FUNCTION get_header_info
  (p_ae_header_id	IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2)
RETURN t_je_info
IS
  CURSOR c_header IS
  	SELECT	 xah.ae_header_id
  		,xah.ledger_id
  		,xte.legal_entity_id
  		,xah.application_id
  		,xah.entity_id
  		,xah.event_id
		,xah.accounting_date
 		,xah.accounting_entry_status_code
		,xah.accounting_entry_type_code
  		,xah.description
  		,xah.balance_type_code
  		,xah.budget_version_id
  		,xah.reference_date
  		,xah.funds_status_code
  		,xah.je_category_name
  		,xah.packet_id
  		,xah.amb_context_code
  		,xah.event_type_code
  		,xah.completed_date
  		,xah.gl_transfer_status_code
  		,xah.accounting_batch_id
  		,xah.period_name
  		,xah.product_rule_code
  		,xah.product_rule_type_code
  		,xah.product_rule_version
  		,xah.gl_transfer_date
  		,xah.doc_sequence_id
  		,xah.doc_sequence_value
  		,xah.close_acct_seq_version_id
  		,xah.close_acct_seq_value
  		,xah.close_acct_seq_assign_id
  		,xah.completion_acct_seq_version_id
  		,xah.completion_acct_seq_value
  		,xah.completion_acct_seq_assign_id
  		,NVL(xah.accrual_reversal_flag,'N')  -- 4262811
  		,xe.budgetary_control_flag
  		,xah.attribute_category
  		,xah.attribute1
  		,xah.attribute2
  		,xah.attribute3
  		,xah.attribute4
  		,xah.attribute5
  		,xah.attribute6
  		,xah.attribute7
  		,xah.attribute8
  		,xah.attribute9
  		,xah.attribute10
  		,xah.attribute11
  		,xah.attribute12
  		,xah.attribute13
  		,xah.attribute14
  		,xah.attribute15
    FROM	xla_ae_headers           xah
               ,xla_events               xe
               ,xla_transaction_entities xte
    WHERE	xte.entity_id		= xah.entity_id
      AND       xte.application_id      = xah.application_id
      AND       xe.event_id             = xah.event_id
      AND       xe.application_id       = xah.application_id
      AND	xah.ae_header_id 	= p_ae_header_id
      AND	xah.application_id	= p_application_id
    FOR UPDATE NOWAIT;


  l_info	t_je_info;
  l_log_module          VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_header_info';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_header_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c_header;
  FETCH c_header INTO 	 l_info.header_id
			,l_info.ledger_id
  			,l_info.legal_entity_id
  			,l_info.application_id
  			,l_info.entity_id
  			,l_info.event_id
  			,l_info.gl_date
  			,l_info.status_code
  			,l_info.type_code
  			,l_info.description
  			,l_info.balance_type_code
  			,l_info.budget_version_id
  			,l_info.reference_date
  			,l_info.funds_status_code
  			,l_info.je_category_name
  			,l_info.packet_id
  			,l_info.amb_context_code
  			,l_info.event_type_code
  			,l_info.completed_date
  			,l_info.gl_transfer_status_code
  			,l_info.accounting_batch_id
  			,l_info.period_name
  			,l_info.product_rule_code
  			,l_info.product_rule_type_code
  			,l_info.product_rule_version
  			,l_info.gl_transfer_date
  			,l_info.doc_sequence_id
  			,l_info.doc_sequence_value
  			,l_info.close_acct_seq_version_id
  			,l_info.close_acct_seq_value
  			,l_info.close_acct_seq_assign_id
  			,l_info.completion_acct_seq_version_id
  			,l_info.completion_acct_seq_value
  			,l_info.completion_acct_seq_assign_id
  			,l_info.accrual_reversal_flag    -- 4262811
  		        ,l_info.budgetary_control_flag
  			,l_info.attribute_category
  			,l_info.attribute1
  			,l_info.attribute2
  			,l_info.attribute3
  			,l_info.attribute4
  			,l_info.attribute5
  			,l_info.attribute6
  			,l_info.attribute7
  			,l_info.attribute8
  			,l_info.attribute9
  			,l_info.attribute10
  			,l_info.attribute11
  			,l_info.attribute12
  			,l_info.attribute13
  			,l_info.attribute14
  			,l_info.attribute15;
  CLOSE c_header;

  IF (l_info.ledger_id IS NULL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_HEADER_ID'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_header_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_info;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_header%ISOPEN) THEN
    CLOSE c_header;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c_header%ISOPEN) THEN
    CLOSE c_header;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.get_header_info');
END get_header_info;


--=============================================================================
--
-- Name: validate_code_combination_id
-- Description: Validate a code combination id.
--
--=============================================================================
PROCEDURE validate_code_combination_id
   (p_line_num              IN  INTEGER
   ,p_code_combination_id   IN  INTEGER
   ,p_msg_mode		    IN  VARCHAR2 DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  CURSOR C IS
    SELECT code_combination_id
      FROM gl_code_combinations
     WHERE code_combination_id = p_code_combination_id;

  l_ccid	        INTEGER := NULL;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_code_combination_id';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_code_combination_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN C;
  FETCH C INTO l_ccid;
  CLOSE C;

  IF (l_ccid IS NULL) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_AP_INVALID_CCID',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_AP_INVALID_CCID'
	 ,p_token_1		=> 'ACCOUNT_VALUE'
	 ,p_value_1		=> NULL
	 ,p_token_2		=> 'LINE_NUM'
	 ,p_value_2		=> p_line_num
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_code_combination_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.validate_code_combination_id');
END validate_code_combination_id;


--=============================================================================
--
-- Name: validate_ae_status_code
-- Description: Validate an accounting entry status code is not final.
--
--=============================================================================
PROCEDURE validate_ae_status_code
   (p_status_code       IN  VARCHAR2
   ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ae_status_code';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_ae_status_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Check to ensure the journal entry is not final
  --
  IF (p_status_code in (C_AE_STATUS_FINAL)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_AE_STATUS',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_AE_STATUS'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_ae_status_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.validate_ae_status_code');
END validate_ae_status_code;


--=============================================================================
--
-- Name: validate_ae_type_code
-- Description: Validate an accounting entry type code.
--
--=============================================================================
PROCEDURE validate_ae_type_code
  (p_accounting_entry_type_code	IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ae_type_code';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_ae_type_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_accounting_entry_type_code NOT in (C_TYPE_MANUAL,
					   C_TYPE_UPGRADE,
					   C_TYPE_MERGE)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_AE_TYPE',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_AE_TYPE'
	 ,p_token_1		=> 'TYPE'
	 ,p_value_1		=> p_accounting_entry_type_code
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_ae_type_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_ae_type_code');
END validate_ae_type_code;


--=============================================================================
--
-- Name: validate_line_number
-- Description: Validate a line number.
--
--=============================================================================

PROCEDURE validate_line_number
  (p_header_id     	IN  INTEGER
  ,p_line_num		IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  CURSOR c IS
    SELECT ae_line_num
     FROM  xla_ae_lines
    WHERE  ae_header_id = p_header_id
      AND  ae_line_num = p_line_num
      AND  application_id = p_application_id;

  l_line_num 	        INTEGER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_line_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_line_num;
  CLOSE c;

  IF (l_line_num IS NULL) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_LINE_NUM: '||p_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_LINE_NUM'
	 ,p_token_1		=> 'LINE_NUM'
	 ,p_value_1		=> p_line_num
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_line_number`');
END validate_line_number;

--=============================================================================
--
-- Name: validate_display_line_number
-- Description: Validate a display line number
--
--=============================================================================
PROCEDURE validate_display_line_number
  (p_header_id     	IN  INTEGER
  ,p_line_num		IN  INTEGER
  ,p_display_line_num	IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  CURSOR c IS
    SELECT ae_line_num
     FROM  xla_ae_lines
    WHERE  ae_header_id          = p_header_id
      AND  ae_line_num           <> nvl(p_line_num,-1)
      AND  displayed_line_number = p_display_line_num
      AND  application_id        = p_application_id;

  l_line_num 	        INTEGER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_display_line_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_display_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_line_num;
  CLOSE c;

  IF (l_line_num IS NOT NULL) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_LINE_NUM_EXIST: '||p_display_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_LINE_NUM_EXIST'
	 ,p_token_1		=> 'LINE_NUM'
	 ,p_value_1		=> p_display_line_num
	 ,p_msg_mode		=> p_msg_mode);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_display_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_display_line_number`');

END validate_display_line_number;


--=============================================================================
--
-- Name: validate_lines
-- Description: Validate line information.
--
-- Return Code: 0 - success
--              1 - failed
--
--=============================================================================
FUNCTION validate_lines
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_ae_header_id	IN  INTEGER)
RETURN INTEGER
IS
  CURSOR c_line IS
    SELECT ae_line_num, accounting_class_code, gl_transfer_mode_code
      FROM xla_ae_lines
     WHERE ae_header_id    = p_ae_header_id
       AND application_id  = p_application_id;

  l_retcode		INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_lines';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - validate line',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_line IN c_line LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP validate line: ae_line_num = '||l_line.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    IF (l_line.gl_transfer_mode_code IS NOT NULL AND
	l_line.gl_transfer_mode_code NOT in (C_GL_TRANSFER_SUMMARY, C_GL_TRANSFER_DETAIL)) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_INVALID_GL_TRAN_MODE',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_GL_TRAN_MODE'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => l_line.ae_line_num
        ,p_accounting_batch_id  => NULL);
      l_retcode := 1;
    END IF;

    IF (length(trim(l_line.accounting_class_code)) = 0 OR
        l_line.accounting_class_code IS NULL) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_NO_ACCT_CLASS',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_NO_ACCT_CLASS'
	,p_token_1		=> 'LINE_NUM'
	,p_value_1		=> l_line.ae_line_num
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => l_line.ae_line_num
        ,p_accounting_batch_id  => NULL);
      l_retcode := 1;
    END IF;

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - validate line',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_lines',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_line%ISOPEN) THEN
    CLOSE c_line;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c_line%ISOPEN) THEN
    CLOSE c_line;
  END IF;
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.validate_lines');
END validate_lines;

--=============================================================================
--
-- Name: validate_completion_action
-- Description: Validation the completion option.
--
-- Return Code: 0 - success
--              1 - failed
--
--=============================================================================
FUNCTION validate_completion_action
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_completion_option 	IN  VARCHAR2)
RETURN INTEGER
IS
  l_retcode	        INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_completion_action';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_completion_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_completion_option NOT in ( C_COMPLETION_OPTION_DRAFT,
				   C_COMPLETION_OPTION_FINAL,
			      	   C_COMPLETION_OPTION_TRANSFER,
				   C_COMPLETION_OPTION_POST)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_COMP_OPT',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_COMP_OPT'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    l_retcode := 1;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_completion_action',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.validate_completion_action');
END validate_completion_action;




--=============================================================================
--
-- Name: is_budgetary_control_enabled
-- Description: Determine if budgetary control is enabled for a ledger
--
-- Return Code: TRUE  - budgetary control is enabled
--              FALSE - budgetary control is not enabled
--
--=============================================================================
FUNCTION is_budgetary_control_enabled
  (p_ledger_id		IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_bc_enabled IS
    SELECT	ledger_id, nvl(enable_budgetary_control_flag, 'N')
    FROM	gl_ledgers
    WHERE	ledger_id = p_ledger_id;

  l_bc_enabled	VARCHAR2(30);
  l_ledger_id	INTEGER;
  l_return	BOOLEAN;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.is_budgetary_control_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure is_budgetary_control_enabled',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c_bc_enabled;
  FETCH c_bc_enabled INTO l_ledger_id, l_bc_enabled;
  CLOSE c_bc_enabled;

  IF (l_ledger_id IS NULL) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_LEDGER_ID',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_LEDGER_ID'
	 ,p_token_1		=> 'LEDGER_ID'
	 ,p_value_1		=> p_ledger_id
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (l_bc_enabled = 'N') THEN
    l_return := FALSE;
  ELSE
    l_return := TRUE;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure is_budgetary_control_enabled',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_bc_enabled%ISOPEN) THEN
    CLOSE c_bc_enabled;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c_bc_enabled%ISOPEN) THEN
    CLOSE c_bc_enabled;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.is_budgetary_control_enabled');

END is_budgetary_control_enabled;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE undo_draft_entry
  (p_info	        IN  t_je_info)
IS
  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.undo_draft_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure undo_draft_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'status code = '||p_info.status_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (p_info.status_code = C_AE_STATUS_DRAFT) THEN
    --
    -- If the entry was a draft entry, call update balance to reverse draft balance
    --
    IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
	IF (NOT xla_balances_pkg.massive_update
			(p_application_id 	=> p_info.application_id
			,p_ledger_id		=> NULL
			,p_event_id		=> NULL
			,p_entity_id		=> p_info.entity_id
			,p_request_id		=> NULL
			,p_accounting_batch_id	=> NULL
			,p_update_mode		=> C_BALANCE_DELETE
			,p_execution_mode	=> C_BALANCE_ONLINE)) THEN
	  xla_exceptions_pkg.raise_message
	  (p_appli_s_name	=> 'XLA'
	  ,p_msg_name		=> 'XLA_INTERNAL_ERROR'
	  ,p_token_1            => 'MESSAGE'
	  ,p_value_1            => 'Error in balance calculation'
	  ,p_token_2            => 'LOCATION'
	  ,p_value_2            => 'XLA_JOURNAL_ENTRIES_PKG.update_journal_entry_header'
	  ,p_msg_mode		=> xla_exceptions_pkg.C_STANDARD_MESSAGE);
       END IF;
     ELSE
	IF (NOT xla_balances_calc_pkg.massive_update
			(p_application_id 	=> p_info.application_id
			,p_ledger_id		=> NULL
			,p_event_id		=> NULL
			,p_entity_id		=> p_info.entity_id
			,p_request_id		=> NULL
			,p_accounting_batch_id	=> NULL
			,p_update_mode		=> C_BALANCE_DELETE
			,p_execution_mode	=> C_BALANCE_ONLINE)) THEN

	  xla_exceptions_pkg.raise_message
		  (p_appli_s_name	=> 'XLA'
		  ,p_msg_name		=> 'XLA_INTERNAL_ERROR'
		  ,p_token_1            => 'MESSAGE'
		  ,p_value_1            => 'Error in balance calculation'
		  ,p_token_2            => 'LOCATION'
		  ,p_value_2            => 'XLA_JOURNAL_ENTRIES_PKG.delete_journal_entries'
	  ,p_msg_mode		=> xla_exceptions_pkg.C_STANDARD_MESSAGE);
	END IF;
     END IF;

    --
    -- Delete the MRC entries created for the draft entry
    --
    delete_mrc_entries(p_info.event_id, p_info.application_id, p_info.ledger_id);

    --
    -- Update the event process status to unprocessed
    --
    l_event_source_info.application_id := p_info.application_id;
    l_event_source_info.legal_entity_id := p_info.legal_entity_id;
    l_event_source_info.ledger_id := p_info.ledger_id;
    l_event_source_info.entity_type_code := C_ENTITY_TYPE_CODE_MANUAL;

    xla_events_pkg.update_manual_event
     		(p_event_source_info 	=> l_event_source_info
     		,p_event_id		=> p_info.event_id
     		,p_event_status_code    => xla_events_pub_pkg.C_EVENT_UNPROCESSED
     		,p_process_status_code	=> xla_events_pkg.C_INTERNAL_UNPROCESSED);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure undo_draft_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.undo_draft_entry');
END undo_draft_entry;



--=============================================================================
--
-- Name: validate_reversal_method
-- Description: Validate the reversal method option.
--
-- Return Code: 0 - success
--              1 - failed
--
--=============================================================================
FUNCTION validate_reversal_method
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_reversal_method   	IN  VARCHAR2)
RETURN INTEGER
IS
  l_retcode	        INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_reversal_method';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_reversal_method',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_reversal_method NOT in (C_REVERSAL_CHANGE_SIGN, C_REVERSAL_SWITCH_DR_CR)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_REV_OPT',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_REV_OPT'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    l_retcode := 1;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_reversal_method',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_reversal_method');
END validate_reversal_method;


--=============================================================================
--
-- Name: create_mrc_reversal_entry
-- Description: Create reversal entry for mrc journal entry
--
--=============================================================================
PROCEDURE create_mrc_reversal_entry
  (p_info               IN  t_je_info
  ,p_reversal_method    IN  VARCHAR2
  ,p_orig_event_id      IN  NUMBER
  ,p_ledger_ids         IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_rev_ae_header_ids  IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_rev_status_codes   IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar)
IS
  l_event_source_info   xla_events_pub_pkg.t_event_source_info;
  l_entity_id           INTEGER;
  l_period_name         VARCHAR2(30);
  l_closing_status      VARCHAR2(30);
  l_validate_period     INTEGER;
  l_result              INTEGER;
  l_period_type         VARCHAR2(30);
  l_reversal_label      VARCHAR2(240);

  l_last_updated_by     INTEGER;
  l_last_update_login   INTEGER;
  i                     INTEGER :=1;

  ------------------------------------------------------------------------------
  -- 5109240
  -- Modify to select both ALC and Secondary journal entries and also
  -- if there is MPA/Accrual Reversal entries.
  ------------------------------------------------------------------------------
  /*
  CURSOR c_mrc_headers IS
    SELECT xah.*
      FROM xla_ae_headers xah
           , xla_alt_curr_ledgers_v l
     WHERE xah.application_id  = p_info.application_id
       AND xah.event_id        = p_orig_event_id
       AND xah.ledger_id       = l.ledger_id
       AND l.primary_ledger_id = p_info.ledger_id
       AND l.enabled_flag      = 'Y';
  */
  CURSOR c_mrc_headers IS
  SELECT xah.*
  FROM   xla_ae_headers xah
       , xla_ledger_relationships_v l
  WHERE xah.application_id   = p_info.application_id
    AND xah.event_id         = p_orig_event_id
    AND xah.ledger_id        = l.ledger_id
    -- AND l.primary_ledger_id  = p_info.ledger_id -- bug#8736946
    AND  (l.LEDGER_CATEGORY_CODE IN ('ALC','SECONDARY')
    OR   (l.LEDGER_CATEGORY_CODE= 'PRIMARY' AND xah.parent_ae_header_id IS NOT NULL));

  l_log_module          VARCHAR2(240);

  l_accounting_date xla_ae_headers.accounting_date%TYPE;


BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_mrc_reversal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_mrc_reversal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_orig_event_id:'||to_char(p_orig_event_id),
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_last_updated_by    := nvl(xla_environment_pkg.g_usr_id,-1);
  l_last_update_login  := nvl(xla_environment_pkg.g_login_id,-1);

  fnd_message.set_name('XLA', 'XLA_MJE_LABEL_REVERSAL');
  l_reversal_label     := fnd_message.get();

  FOR l_mrc_header IN c_mrc_headers LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - mrc header: ae_header_id = '||l_mrc_header.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i+1;
    p_ledger_ids(i) := l_mrc_header.ledger_id;
    p_rev_status_codes(i) := p_rev_status_codes(1);

  --Call get_period_name function to derive period_name.
  --For bug 8629346
    l_period_name := get_period_name(p_ledger_id       => l_mrc_header.ledger_id
  		  		    ,p_accounting_date => p_info.gl_date
				    ,p_closing_status  => l_closing_status
				    ,p_period_type     => l_period_type);

   l_accounting_date := p_info.gl_date;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
     trace(p_msg    => 'l_period_name = '||l_period_name,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

   -- Reversal Date is less than the MPA accounting date then create the MPA reversal with the
    -- original MPA events accounting date
    IF ( l_mrc_header.parent_ae_header_id IS NOT NULL AND p_info.gl_date < l_mrc_header.accounting_date ) THEN
    -- indicates an MPA accounting entry
     l_period_name := l_mrc_header.period_name;
     l_accounting_date := l_mrc_header.accounting_date;
    END IF;


    --
    -- Create a new journal entry header
    --
    INSERT INTO xla_ae_headers
     (ae_header_id
     ,application_id
     ,ledger_id
     ,entity_id
     ,event_id
     ,event_type_code
     ,accounting_date
     ,period_name
     ,reference_date
     ,balance_type_code
     ,budget_version_id
     ,encumbrance_type_id
     ,gl_transfer_status_code
     ,je_category_name
     ,accounting_entry_status_code
     ,accounting_entry_type_code
     ,description
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,accrual_reversal_flag -- 5109240
     ,parent_ae_header_id
      )
    values
     (xla_ae_headers_s.NEXTVAL
     ,l_mrc_header.application_id
     ,l_mrc_header.ledger_id
     ,p_info.entity_id
     ,p_info.event_id
     ,C_EVENT_TYPE_CODE_MANUAL
     ,l_accounting_date --p_info.gl_date
     ,l_period_name  --p_info.period_name 8629346 : Derive period_name for secondary/ALC ledger
     ,p_info.reference_date
     ,l_mrc_header.balance_type_code
     ,l_mrc_header.budget_version_id
     ,l_mrc_header.encumbrance_type_id
     ,C_GL_TRANSFER_MODE_NO
     ,l_mrc_header.je_category_name
     ,C_AE_STATUS_INCOMPLETE
     ,p_info.type_code
     ,l_reversal_label||': '||l_mrc_header.description
     ,sysdate
     ,l_last_updated_by
     ,sysdate
     ,l_last_updated_by
     ,l_last_update_login
     ,NVL(l_mrc_header.accrual_reversal_flag,'N')
     ,l_mrc_header.parent_ae_header_id
     )  -- 5109240
    RETURNING ae_header_id INTO p_rev_ae_header_ids(i);

    --
    -- Copy header analytical criteria FROM the original entry to the reversal entry
    --
    INSERT INTO xla_ae_header_acs(
           ae_header_id
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,object_version_number)
   SELECT  p_rev_ae_header_ids(i)
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,1
     FROM  xla_ae_header_acs
    WHERE ae_header_id = l_mrc_header.ae_header_id;

    --
    -- Create journal entry lines for the reversal journal entry
    --
    INSERT INTO xla_ae_lines
       (application_id
       ,ae_header_id
       ,ae_line_num
       ,displayed_line_number
       ,code_combination_id
       ,gl_transfer_mode_code
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,party_id
       ,party_site_id
       ,party_type_code
       ,unrounded_entered_dr
       ,unrounded_entered_cr
       ,entered_dr
       ,entered_cr
       ,unrounded_accounted_dr
       ,unrounded_accounted_cr
       ,accounted_dr
       ,accounted_cr
       ,description
       ,statistical_amount
       ,currency_code
       ,currency_conversion_type
       ,currency_conversion_date
       ,currency_conversion_rate
       ,accounting_class_code
       ,jgzz_recon_ref
       ,gl_sl_link_table
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,ledger_id
       ,accounting_date
       ,encumbrance_type_id  -- Added for bug 7605412
       ,gain_or_loss_flag
       ,mpa_accrual_entry_flag)  -- 4262811
      SELECT
        application_id
       ,p_rev_ae_header_ids(i)
       ,ae_line_num
       ,displayed_line_number
       ,code_combination_id
       ,gl_transfer_mode_code
       ,sysdate
       ,l_last_updated_by
       ,sysdate
       ,l_last_updated_by
       ,l_last_update_login
       ,party_id
       ,party_site_id
       ,party_type_code
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                unrounded_entered_cr, -unrounded_entered_dr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                unrounded_entered_dr, -unrounded_entered_cr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                entered_cr, -entered_dr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                entered_dr, -entered_cr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                unrounded_accounted_cr, -unrounded_accounted_dr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                unrounded_accounted_dr, -unrounded_accounted_cr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                accounted_cr, -accounted_dr)
       ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
                                accounted_dr, -accounted_cr)
       ,description
       ,statistical_amount
       ,currency_code
       ,currency_conversion_type
       ,currency_conversion_date
       ,currency_conversion_rate
       ,accounting_class_code
       ,jgzz_recon_ref
       ,'XLAJEL'
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,l_mrc_header.ledger_id
       ,p_info.gl_date
       ,encumbrance_type_id  -- Added for bug 7605412
       ,gain_or_loss_flag
       ,NVL(mpa_accrual_entry_flag,'N')
      FROM      xla_ae_lines
      WHERE     application_id = p_info.application_id
      AND       ae_header_id = l_mrc_header.ae_header_id;

    create_reversal_distr_link
      (p_application_id     => p_info.application_id
      ,p_ae_header_id       => p_rev_ae_header_ids(i)
      ,p_ref_ae_header_id   => l_mrc_header.ae_header_id
      ,p_ref_event_id       => p_orig_event_id);

    --
    -- Copy the journal entry lines' analytical criteria from the original entry to
    -- the reversal entry
    --
    INSERT INTO xla_ae_line_acs(
           ae_header_id
          ,ae_line_num
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,object_version_number)
    SELECT p_rev_ae_header_ids(i)
          ,ae_line_num
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,1
      FROM xla_ae_line_acs
     WHERE ae_header_id = l_mrc_header.ae_header_id;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of procedure create_mrc_reversal_entry',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;
  END LOOP;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK ;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.create_mrc_reversal_entry');

END create_mrc_reversal_entry;


--=============================================================================
--
-- Name: create_reversal_entry
-- Description: Create reversal entry for a journal entry
--
--=============================================================================
PROCEDURE create_reversal_entry
  (p_info	        IN  t_je_info
  ,p_reversal_method	IN  VARCHAR2
  ,p_gl_date		IN  DATE
  ,p_msg_mode       	IN  VARCHAR2
  ,p_rev_header_id	OUT NOCOPY INTEGER
  ,p_rev_event_id	OUT NOCOPY INTEGER)
IS
  l_event_source_info	xla_events_pub_pkg.t_event_source_info;
  l_entity_id		INTEGER;
  l_period_name		VARCHAR2(30);
  l_closing_status	VARCHAR2(30);
  l_validate_period	INTEGER;
  l_result		INTEGER;
  l_period_type		VARCHAR2(30);
  l_reversal_label      VARCHAR2(240);

  l_last_updated_by     INTEGER;
  l_last_update_login   INTEGER;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_reversal_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_reversal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_period_name := get_period_name
	(p_ledger_id		=> p_info.ledger_id
	,p_accounting_date	=> p_gl_date
	,p_closing_status	=> l_closing_status
	,p_period_type		=> l_period_type);

  IF (l_period_name IS NULL) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
	 ,p_msg_name		=> 'XLA_AP_INVALID_GL_DATE'
         ,p_token_1             => 'GL_DATE'
         ,p_value_1             => to_char(p_gl_date,'DD-MON-YYYY')
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  --
  -- Create event for the reversal entry
  --
  l_event_source_info.application_id := p_info.application_id;
  l_event_source_info.legal_entity_id := p_info.legal_entity_id;
  l_event_source_info.ledger_id := p_info.ledger_id;
  l_event_source_info.entity_type_code := C_ENTITY_TYPE_CODE_MANUAL;

/* Bug 7011889 - If reversal event is already created for Actual, do not call for Encumbarance.
               - Checking that g_rev_event_id is not NULL to create event */

IF g_rev_event_id IS NULL THEN

   p_rev_event_id := xla_events_pkg.create_manual_event
   (p_event_source_info 	  => l_event_source_info
   ,p_event_type_code             => C_EVENT_TYPE_CODE_MANUAL
   ,p_event_date                  => p_gl_date
   ,p_event_status_code           => xla_events_pub_pkg.C_EVENT_UNPROCESSED
   ,p_process_status_code	  => xla_events_pkg.C_INTERNAL_UNPROCESSED
   ,p_event_number                => 1
   ,p_budgetary_control_flag      => p_info.budgetary_control_flag
   );
   g_rev_event_id := p_rev_event_id;

   SELECT 	entity_id
   INTO 	g_entity_id
   FROM		xla_events
   WHERE	event_id = p_rev_event_id;

   l_entity_id := g_entity_id;

ELSE
 /* Bug 7011889 - If already an event is created, make use of the same for Encumbarance */

  p_rev_event_id := g_rev_event_id;
  l_entity_id := g_entity_id;
END IF;


  fnd_message.set_name('XLA', 'XLA_MJE_LABEL_REVERSAL');
  l_reversal_label     := fnd_message.get();

  l_last_updated_by    := nvl(xla_environment_pkg.g_usr_id,-1);
  l_last_update_login  := nvl(xla_environment_pkg.g_login_id,-1);

  --
  -- Create a new journal entry header
  --

  INSERT INTO xla_ae_headers
   (ae_header_id
   ,application_id
   ,ledger_id
   ,entity_id
   ,event_id
   ,event_type_code
   ,accounting_date
   ,period_name
   ,reference_date
   ,balance_type_code
   ,budget_version_id
   ,gl_transfer_status_code
   ,je_category_name
   ,accounting_entry_status_code
   ,accounting_entry_type_code
   ,description
   ,creation_date
   ,created_by
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,accrual_reversal_flag)  -- 4262811
  values
   (xla_ae_headers_s.NEXTVAL
   ,p_info.application_id
   ,p_info.ledger_id
   ,l_entity_id
   ,p_rev_event_id
   ,C_EVENT_TYPE_CODE_MANUAL
   ,p_gl_date
   ,l_period_name
   ,p_info.reference_date
   ,p_info.balance_type_code
   ,p_info.budget_version_id
   ,C_GL_TRANSFER_MODE_NO
   ,p_info.je_category_name
   ,C_AE_STATUS_INCOMPLETE
   ,p_info.type_code
   ,l_reversal_label||': '||p_info.description
   ,sysdate
   ,l_last_updated_by
   ,sysdate
   ,l_last_updated_by
   ,l_last_update_login
   ,NVL(p_info.accrual_reversal_flag,'N'))             -- 4262811 accrual_reversal_flag
  RETURNING ae_header_id INTO p_rev_header_id;

  --
  -- Copy header analytical criteria FROM the original entry to the reversal entry
  --
  INSERT INTO xla_ae_header_acs(
         ae_header_id
        ,analytical_criterion_code
        ,analytical_criterion_type_code
        ,amb_context_code
        ,ac1
        ,ac2
        ,ac3
        ,ac4
        ,ac5
        ,object_version_number)
  SELECT p_rev_header_id
        ,analytical_criterion_code
        ,analytical_criterion_type_code
        ,amb_context_code
        ,ac1
        ,ac2
        ,ac3
        ,ac4
        ,ac5
        ,1
    FROM xla_ae_header_acs
   WHERE ae_header_id = p_info.header_id;


  --
  -- Create journal entry lines for the reversal journal entry
  --
  INSERT INTO xla_ae_lines
     (application_id
     ,ae_header_id
     ,ae_line_num
     ,displayed_line_number
     ,code_combination_id
     ,gl_transfer_mode_code
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,party_id
     ,party_site_id
     ,party_type_code
     ,entered_dr
     ,entered_cr
     ,accounted_dr
     ,accounted_cr
     ,unrounded_entered_dr   -- 5109240
     ,unrounded_entered_cr   -- 5109240
     ,unrounded_accounted_dr -- 5109240
     ,unrounded_accounted_cr -- 5109240
     ,description
     ,statistical_amount
     ,currency_code
     ,currency_conversion_type
     ,currency_conversion_date
     ,currency_conversion_rate
     ,accounting_class_code
     ,jgzz_recon_ref
     ,gl_sl_link_table
     ,attribute_category
     ,encumbrance_type_id
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,gain_or_loss_flag
     ,ledger_id
     ,accounting_date
     ,mpa_accrual_entry_flag)  -- 4262811
    SELECT
      application_id
     ,p_rev_header_id
     ,ae_line_num
     ,displayed_line_number
     ,code_combination_id
     ,gl_transfer_mode_code
     ,sysdate
     ,l_last_updated_by
     ,sysdate
     ,l_last_updated_by
     ,l_last_update_login
     ,party_id
     ,party_site_id
     ,party_type_code
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				entered_cr, -entered_dr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				entered_dr, -entered_cr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				accounted_cr, -accounted_dr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				accounted_dr, -accounted_cr)
     -- 5109240 unrounded amounts
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				unrounded_entered_cr,   -unrounded_entered_dr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				unrounded_entered_dr,   -unrounded_entered_cr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				unrounded_accounted_cr, -unrounded_accounted_dr)
     ,DECODE(p_reversal_method, C_REVERSAL_SWITCH_DR_CR,
				unrounded_accounted_dr, -unrounded_accounted_cr)
     ,description
     ,statistical_amount
     ,currency_code
     ,currency_conversion_type
     ,currency_conversion_date
     ,currency_conversion_rate
     ,accounting_class_code
     ,jgzz_recon_ref
     ,'XLAJEL'
     ,attribute_category
     ,encumbrance_type_id
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,gain_or_loss_flag
     ,p_info.ledger_id
     ,p_gl_date
     ,NVL(mpa_accrual_entry_flag,'N')     -- 4262811 mpa_accrual_entry_flag
    FROM 	xla_ae_lines
    WHERE 	application_id = p_info.application_id
    AND		ae_header_id = p_info.header_id;


  create_reversal_distr_link
    (p_application_id     => p_info.application_id
    ,p_ae_header_id       => p_rev_header_id
    ,p_ref_ae_header_id   => p_info.header_id -- Original Ae Header
    ,p_ref_event_id       => NULL);

  --
  -- Copy the journal entry lines' analytical criteria from the original entry to
  -- the reversal entry
  --
  INSERT INTO xla_ae_line_acs(
         ae_header_id
        ,ae_line_num
        ,analytical_criterion_code
        ,analytical_criterion_type_code
        ,amb_context_code
        ,ac1
        ,ac2
        ,ac3
        ,ac4
        ,ac5
        ,object_version_number)
  SELECT p_rev_header_id
	,ae_line_num
        ,analytical_criterion_code
        ,analytical_criterion_type_code
        ,amb_context_code
        ,ac1
        ,ac2
        ,ac3
        ,ac4
        ,ac5
        ,1
    FROM xla_ae_line_acs
   WHERE ae_header_id = p_info.header_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_reversal_entry',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK ;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.create_reversal_entry');

END create_reversal_entry;


--=============================================================================
--
-- Name: reorder_line_number
-- Description: Reorder order line number
--
--=============================================================================
PROCEDURE reorder_line_number
  (p_application_id	IN  INTEGER
  ,p_ae_header_id	IN  INTEGER)
IS
  CURSOR c_lines IS
    SELECT ae_line_num
      FROM xla_ae_lines
     WHERE application_id    = p_application_id
       AND ae_header_id      = p_ae_header_id
     ORDER BY ae_line_num;

  l_ae_line_nums      	t_array_int;
  l_displayed_nums	t_array_int;
  i			INTEGER := 0;
  j			INTEGER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reorder_line_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reorder_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - reorder line number',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_line IN c_lines LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - reorder line number: ae_line_num = '||l_line.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i+1;
    l_ae_line_nums(i) := l_line.ae_line_num;
    l_displayed_nums(i) := i;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - reorder line number',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FORALL j in 1..i
    UPDATE xla_ae_lines
      	set 	displayed_line_number = l_displayed_nums(j)
	WHERE	application_id = p_application_id
	AND	ae_header_id = p_ae_header_id
	AND	ae_line_num = l_ae_line_nums(j);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reorder_line_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.reorder_line_number');

END reorder_line_number;


--=============================================================================
--
-- Name: reserve_funds
-- Description: Reserve funds when completing a final entry.
--
-- Return code: C_COMPLETION_SUCCESS, C_COMPLETION_FAILED
--
--=============================================================================
FUNCTION reserve_funds
  (p_info	         IN OUT NOCOPY t_je_info
  ,p_msg_mode            IN            VARCHAR2)
RETURN VARCHAR2
IS
  l_retcode             VARCHAR2(30) := C_COMPLETION_SUCCESS;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.reserve_funds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure reserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_info.budgetary_control_flag = 'Y' AND
      is_budgetary_control_enabled(p_info.ledger_id, p_msg_mode)) THEN

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'is_budgetary_control_enabled is TRUE',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    p_info.funds_status_code := xla_je_funds_checker_pkg.reserve_funds(
			p_ae_header_id		=> p_info.header_id,
			p_application_id 	=> p_info.application_id,
			p_ledger_id		=> p_info.ledger_id,
			p_packet_id		=> p_info.packet_id);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'funds_status_code = '||p_info.funds_status_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    IF (p_info.funds_status_code IN (C_FUNDS_FAILED, C_FUNDS_PARTIAL)) THEN
      l_retcode := C_COMPLETION_FAILED;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_CHECK_FUNDS_FAILED'
        ,p_entity_id            => p_info.entity_id
        ,p_event_id             => p_info.event_id
        ,p_ledger_id            => p_info.ledger_id
        ,p_ae_header_id         => p_info.header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure reserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.reserve_funds');
END reserve_funds;

--=============================================================================
--
-- Name: get_sequence_number
-- Description: Get the sequence number for a journal entry.
--
--=============================================================================
FUNCTION get_sequence_number
  (p_info	        	IN         t_je_info
  ,p_je_source_name		IN         VARCHAR2
  ,p_completed_date             IN         DATE
  ,p_ledger_id			IN         INTEGER
  ,p_comp_seq_version_id	OUT NOCOPY INTEGER
  ,p_comp_seq_value		OUT NOCOPY INTEGER
  ,p_comp_seq_assign_id		OUT NOCOPY INTEGER)
RETURN VARCHAR2
IS
  l_control_attributes	fun_seq.control_attribute_rec_type;
  l_control_dates	fun_seq.control_date_tbl_type := fun_seq.control_date_tbl_type();
  l_seq_error_code	VARCHAR2(30);
  l_retcode		VARCHAR2(30) := C_COMPLETION_SUCCESS;
  l_err_msg             VARCHAR2(400);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_sequence_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_sequence_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'balance_type = '||p_info.balance_type_code||
                      ', journal_source = '||p_je_source_name||
                      ', journal_category = '||p_info.je_category_name,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
    trace(p_msg    => 'completion_date = '||to_char(p_completed_date,'DD-MON-YYYY')||
                      ', gl_date = '||to_char(p_info.gl_date,'DD-MON-YYYY')||
                      ', reference_date = '||to_char(p_info.reference_date,'DD-MON-YYYY'),
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_control_attributes.balance_type 		:= p_info.balance_type_code;
  l_control_attributes.accounting_event_type 	:= 'MANUAL';
  l_control_attributes.journal_source 		:= p_je_source_name;
  l_control_attributes.journal_category 	:= p_info.je_category_name;
  l_control_attributes.accounting_entry_type 	:= 'MANUAL';

  -- We always provides all three control dates and the SSA team will determine
  -- which date to use.
  l_control_dates.EXTEND(3);
  l_control_dates(1).date_type := 'COMPLETION_OR_POSTING_DATE';
  l_control_dates(1).date_value := p_completed_date;
  l_control_dates(2).date_type :=  'GL_DATE';
  l_control_dates(2).date_value := p_info.gl_date;
  l_control_dates(3).date_type :=  'REFERENCE_DATE';
  l_control_dates(3).date_value := p_info.reference_date;

  BEGIN
    fun_seq.get_sequence_number(
			p_context_type    	   => 'LEDGER_AND_CURRENCY',
			p_context_value   	   => to_char(p_ledger_id),
			p_application_Id  	   => C_XLA_APPLICATION_ID,
			p_table_name	  	   => 'XLA_AE_HEADERS',
			p_event_code		   => 'COMPLETION',
			p_control_attribute_rec    => l_control_attributes,
			p_control_date_tbl	   => l_control_dates,
			p_suppress_error 	   => 'N',
			x_seq_version_id 	   => p_comp_seq_version_id,
			x_sequence_number 	   => p_comp_seq_value,
			x_assignment_id		   => p_comp_seq_assign_id,
			x_error_code 		   => l_seq_error_code);
  EXCEPTION
    WHEN OTHERS THEN
      p_comp_seq_version_id := -1;
      p_comp_seq_value := -1;
      p_comp_seq_assign_id := -1;
      l_retcode := C_COMPLETION_FAILED;

      xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'LOCATION'
                ,p_value_1              => 'FUN_SEQ.get_sequence_number'
                ,p_token_2              => 'MESSAGE'
                ,p_value_2              => fnd_message.get
                ,p_entity_id            => p_info.entity_id
                ,p_event_id             => p_info.event_id
                ,p_ledger_id            => p_info.ledger_id
                ,p_ae_header_id         => p_info.header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
  END;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'return: fun_seq.get_sequence_number = '||l_seq_error_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'return: p_comp_seq_version_id       = '||p_comp_seq_version_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'return: p_comp_seq_value            = '||p_comp_seq_value,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => 'return: p_comp_seq_assign_id        = '||p_comp_seq_assign_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (p_comp_seq_version_id IS NULL) THEN
    p_comp_seq_version_id := -1;
  END IF;
  IF (p_comp_seq_value IS NULL) THEN
    p_comp_seq_value := -1;
  END IF;
  IF (p_comp_seq_assign_id IS NULL) THEN
    p_comp_seq_assign_id := -1;
  END IF;

  IF (l_seq_error_code <> 'SUCCESS') THEN
    l_retcode := C_COMPLETION_FAILED;
    xla_accounting_err_pkg.build_message(
                 p_appli_s_name         => 'XLA'
                ,p_msg_name             => 'XLA_INTERNAL_ERROR'
                ,p_token_1              => 'LOCATION'
                ,p_value_1              => 'FUN_SEQ.get_sequence_number'
                ,p_token_2              => 'MESSAGE'
                ,p_value_2              => l_seq_error_code
                ,p_entity_id            => p_info.entity_id
                ,p_event_id             => p_info.event_id
                ,p_ledger_id            => p_info.ledger_id
                ,p_ae_header_id         => p_info.header_id
                ,p_ae_line_num          => NULL
                ,p_accounting_batch_id  => NULL);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_sequence_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.get_sequence_number');
END get_sequence_number;



--=============================================================================
--
-- Name: populate_sequence_numbers
-- Description: Populate sequence number for the transaction ledger entry and
--              MRC entries.
--
--=============================================================================
FUNCTION populate_sequence_numbers
 (p_info                 IN            t_je_info
 ,p_je_source_name       IN            VARCHAR2
 ,p_completed_date       IN            DATE
 ,p_ledger_ids           IN            xla_je_validation_pkg.t_array_int
 ,p_ae_header_ids        IN            xla_je_validation_pkg.t_array_int
 ,p_status_codes         IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar
 ,p_seq_version_ids      IN OUT NOCOPY t_array_int
 ,p_seq_values           IN OUT NOCOPY t_array_int
 ,p_seq_assign_ids       IN OUT NOCOPY t_array_int)
RETURN VARCHAR2
IS
  l_ledger_id            INTEGER;
  l_seq_retcode          VARCHAR2(30);
  l_retcode              VARCHAR2(30) := C_COMPLETION_SUCCESS;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_sequence_numbers';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_sequence_numbers',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  SAVEPOINT POPULATE_SEQUENCE_NUMBERS;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# of ledger id = '||p_ledger_ids.COUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  FOR i IN 1..p_ledger_ids.COUNT LOOP
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Processing ledger id = '||p_ledger_ids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    l_seq_retcode := get_sequence_number
			(p_info			=> p_info
  			,p_je_source_name	=> p_je_source_name
  			,p_completed_date	=> p_completed_date
  			,p_ledger_id		=> p_ledger_ids(i)
  			,p_comp_seq_version_id	=> p_seq_version_ids(i)
  			,p_comp_seq_value	=> p_seq_values(i)
  			,p_comp_seq_assign_id	=> p_seq_assign_ids(i));

    IF (l_seq_retcode = C_COMPLETION_FAILED) THEN
      l_retcode := C_COMPLETION_FAILED;
      p_status_codes(i) := C_AE_STATUS_INVALID;
    END IF;
  END LOOP;

  IF (l_retcode = C_COMPLETION_FAILED) THEN
    ROLLBACK to SAVEPOINT POPULATE_SEQUENCE_NUMBERS;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_sequence_numbers',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK to SAVEPOINT POPULATE_SEQUENCE_NUMBERS;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK to SAVEPOINT POPULATE_SEQUENCE_NUMBERS;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.populate_sequence_numbers');

END populate_sequence_numbers;


--=============================================================================
--
-- Name: create_mrc_entries
-- Description: Create MRC entries.
--
--=============================================================================
FUNCTION create_mrc_entries
  (p_info               IN OUT NOCOPY t_je_info
  ,p_je_source_name	    IN     VARCHAR2
  ,p_ledger_ids         IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_ae_header_ids      IN OUT NOCOPY xla_je_validation_pkg.t_array_int
  ,p_status_codes       IN OUT NOCOPY xla_je_validation_pkg.t_array_varchar)
RETURN VARCHAR2
IS
  CURSOR c_trx_ledger (p_trx_ledger_id INTEGER, p_application_id INTEGER) IS
    SELECT gl.name, gl.currency_code, gl.ledger_category_code, xlo.rounding_rule_code
      FROM gl_ledgers gl, xla_ledger_options xlo
     WHERE gl.ledger_id = p_trx_ledger_id
       AND xlo.application_id = p_application_id
       AND xlo.ledger_id = p_trx_ledger_id;

  CURSOR c_mrc_ledgers IS
    SELECT xlr.target_ledger_id         ledger_id
         , xlr.name                     ledger_name
         , xlr.currency_code            ledger_currency
         , xlr.ALC_DEFAULT_CONV_RATE_TYPE
         , xlr.ALC_INHERIT_CONVERSION_TYPE
         , decode(xlr.ALC_NO_RATE_ACTION_CODE, 'FIND_RATE', nvl(xlr.ALC_MAX_DAYS_ROLL_RATE, -1), 0) max_roll_days
      FROM xla_ledger_relationships_v  xlr
          ,fnd_currencies              fcu
     WHERE xlr.primary_ledger_id          = p_info.ledger_id
       AND xlr.relationship_enabled_flag  = 'Y'
       AND xlr.ledger_category_code       = 'ALC'
       AND fcu.currency_code              = xlr.currency_code;

  CURSOR c_lines (p_mrc_currency VARCHAR2, p_primary_currency VARCHAR2) IS
    SELECT xal.*
         , decode( fc.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xal.accounting_date)) -
                      trunc(fc.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) from_type
         , decode( fc1.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xal.accounting_date)) -
                      trunc(fc1.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) to_type
         , decode( fc2.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xal.accounting_date)) -
                      trunc(fc2.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) primary_type
      FROM xla_ae_lines xal
         , fnd_currencies fc
         , fnd_currencies fc1
         , fnd_currencies fc2
     WHERE xal.ae_header_id      = p_info.header_id
       AND xal.application_id    = p_info.application_id
       AND fc.currency_code      = xal.currency_code
       AND fc1.currency_code     = p_mrc_currency
       and fc2.currency_code     = p_primary_currency
    ORDER BY xal.currency_code
            ,xal.currency_conversion_type
            ,xal.currency_conversion_date
            ,xal.currency_conversion_rate;

  l_trx_ledger_name         VARCHAR2(30);
  l_trx_ledger_currency     VARCHAR2(30);
  l_trx_ledger_category     VARCHAR2(30);
  l_trx_rounding_rule       VARCHAR2(30);

  l_last_curr_code          VARCHAR2(15);
  l_last_conv_type          VARCHAR2(30);
  l_last_conv_date          DATE;
  l_last_conv_rate          NUMBER;

  l_conv_type               VARCHAR2(30);
  l_conv_date               DATE;
  l_conv_rate               NUMBER;

  l_accounted_cr            NUMBER;
  l_accounted_dr            NUMBER;

  l_retcode                 VARCHAR2(30) := C_COMPLETION_SUCCESS;
  i                         INTEGER := 1;

  l_temp_line_num           INTEGER;
  l_ref_temp_line_num       INTEGER;
  l_ref_ae_header_id        INTEGER;
  l_ref_event_id            INTEGER;

  l_last_updated_by         INTEGER;
  l_last_update_login       INTEGER;

  l_log_module              VARCHAR2(240);

  --8629346 : Derive period_name for the secondary/ALC ledger

  l_period_name             VARCHAR2(15);
  l_closing_status          VARCHAR2(30);
  l_period_type             VARCHAR2(30);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.create_mrc_entries';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure create_mrc_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_last_updated_by   := nvl(xla_environment_pkg.g_usr_id,-1);
  l_last_update_login := nvl(xla_environment_pkg.g_login_id,-1);

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - mrc ledgers',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  OPEN c_trx_ledger(p_ledger_ids(1), p_info.application_id);
  FETCH c_trx_ledger INTO l_trx_ledger_name, l_trx_ledger_currency, l_trx_ledger_category, l_trx_rounding_rule;
  CLOSE c_trx_ledger;

  IF (l_trx_ledger_category IN ('PRIMARY', 'NONE')) THEN

  FOR l_mrc_ledger IN c_mrc_ledgers LOOP

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - mrc ledger: ledger_id = '||l_mrc_ledger.ledger_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i+1;
    p_ledger_ids(i) := l_mrc_ledger.ledger_id;
    p_status_codes(i) := p_status_codes(1);

   --Call get_period_name api to derive period_name
   -- Added for bug 8629346
   l_period_name := get_period_name(p_ledger_id       => l_mrc_ledger.ledger_id
			  	   ,p_accounting_date => p_info.gl_date
				   ,p_closing_status  => l_closing_status
				   ,p_period_type     => l_period_type);


    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'process ledger    : '||l_mrc_ledger.ledger_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'ledger_name       = '||l_mrc_ledger.ledger_name,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'ledger currency   = '||l_mrc_ledger.ledger_currency,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'ALC_DEFAULT_CONV_RATE_TYPE = '||l_mrc_ledger.ALC_DEFAULT_CONV_RATE_TYPE,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'ALC_INHERIT_CONVERSION_TYPE = '||l_mrc_ledger.ALC_INHERIT_CONVERSION_TYPE,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'ALC_MAX_DAYS_ROLL_RATE = '||l_mrc_ledger.max_roll_days,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'l_period_name = '||l_period_name,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    INSERT INTO xla_ae_headers
     	(ae_header_id
     	,application_id
     	,amb_context_code
     	,ledger_id
     	,entity_id
     	,event_id
     	,event_type_code
     	,accounting_date
     	,completed_date
     	,reference_date
     	,balance_type_code
     	,budget_version_id
     	,gl_transfer_status_code
     	,je_category_name
     	,accounting_entry_status_code
     	,accounting_entry_type_code
     	,description
     	,accounting_batch_id
     	,period_name
     	,packet_id
     	,product_rule_code
     	,product_rule_type_code
     	,product_rule_version
     	,gl_transfer_date
     	,doc_sequence_id
     	,doc_sequence_value
    	,close_acct_seq_version_id
     	,close_acct_seq_value
     	,close_acct_seq_assign_id
     	,funds_status_code
     	,attribute_category
     	,attribute1
     	,attribute2
     	,attribute3
     	,attribute4
     	,attribute5
     	,attribute6
     	,attribute7
     	,attribute8
     	,attribute9
     	,attribute10
     	,attribute11
     	,attribute12
     	,attribute13
     	,attribute14
     	,attribute15
     	,creation_date
     	,created_by
     	,last_update_date
     	,last_updated_by
     	,last_update_login
        ,accrual_reversal_flag)  -- 4262811
       values(   xla_ae_headers_s.NEXTVAL
     		,p_info.application_id
     		,p_info.amb_context_code
     		,l_mrc_ledger.ledger_id
     		,p_info.entity_id
     		,p_info.event_id
     		,p_info.event_type_code
     		,p_info.gl_date
		,p_info.completed_date
     		,p_info.reference_date
     		,p_info.balance_type_code
     		,p_info.budget_version_id
     		,p_info.gl_transfer_status_code
     		,p_info.je_category_name
     		,p_info.status_code
     		,p_info.type_code
     		,p_info.description
     		,p_info.accounting_batch_id
     		,l_period_name --p_info.period_name 8629346: derive period_name for secondary/ALC ledger
		,p_info.packet_id
     		,p_info.product_rule_code
     		,p_info.product_rule_type_code
     		,p_info.product_rule_version
     		,p_info.gl_transfer_date
     		,p_info.doc_sequence_id
     		,p_info.doc_sequence_value
     		,p_info.close_acct_seq_version_id
     		,p_info.close_acct_seq_value
     		,p_info.close_acct_seq_assign_id
     		,p_info.funds_status_code
     		,p_info.attribute_category
     		,p_info.attribute1
     		,p_info.attribute2
     		,p_info.attribute3
     		,p_info.attribute4
     		,p_info.attribute5
     		,p_info.attribute6
     		,p_info.attribute7
     		,p_info.attribute8
     		,p_info.attribute9
     		,p_info.attribute10
     		,p_info.attribute11
     		,p_info.attribute12
     		,p_info.attribute13
     		,p_info.attribute14
     		,p_info.attribute15
     		,sysdate
     		,l_last_updated_by
     		,sysdate
     		,l_last_updated_by
     		,l_last_update_login
                ,NVL(p_info.accrual_reversal_flag,'N'))   -- 4262811 accrual_reversal_flag
	RETURNING	ae_header_id
	INTO		p_ae_header_ids(i);

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'Created MRC entry = '||p_ae_header_ids(i),
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    --
    -- Copy journal entry analytical criteria from the original entry to the MRC entry
    --
    INSERT INTO xla_ae_header_acs(
           ae_header_id
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,object_version_number)
    SELECT p_ae_header_ids(i)
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,1
      FROM xla_ae_header_acs
     WHERE ae_header_id = p_info.header_id;

    l_last_curr_code := '';
    l_last_conv_type := '';
    l_last_conv_rate := 0;
    l_last_conv_date := sysdate;

    --
    -- Copy journal entry line from the original entry to the mrc entry
    --

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - copy lines',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    For l in c_lines (l_mrc_ledger.ledger_currency, l_trx_ledger_currency) LOOP
      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => 'process line: '||l.ae_line_num||' ('||l.displayed_line_number||') '||
                          ', from_type='||l.from_type||
                          ', to_type='||l.to_type||
                          ', primary_type='||l.primary_type||
                          ', curr='||l.currency_code||
                          ', type='||l.currency_conversion_type,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      IF (l_trx_ledger_currency = l_mrc_ledger.ledger_currency) THEN

        l_conv_type := l.currency_conversion_type;
        l_conv_date := l.currency_conversion_date;
        l_conv_rate := l.currency_conversion_rate;

      ELSIF (l_last_curr_code <> nvl(l.currency_code,C_CHAR) or
             l_last_conv_type <> nvl(l.currency_conversion_type,C_CHAR) or
             l_last_conv_rate <> nvl(l.currency_conversion_rate,C_NUM)) THEN

        --
        -- Compare the currency and conversion info with the previous journal entry line.
        -- Retrieve mrc conversion info from GL only IF they are difference.
        --
        l_last_curr_code := l.currency_code;
        l_last_conv_type := l.currency_conversion_type;
        l_last_conv_date := l.currency_conversion_date;
        l_last_conv_rate := l.currency_conversion_rate;

        IF (l.currency_code = l_mrc_ledger.ledger_currency) THEN

          l_conv_rate := 1;

        ELSE

          l_conv_date := nvl(l.currency_conversion_date,p_info.gl_date);

          BEGIN

            IF (l.from_type IN ('EMU', 'EURO') AND l.to_type IN ('EMU', 'EURO')) THEN

              IF (C_LEVEL_EVENT >= g_log_level) THEN
                trace(p_msg    => ' case 1 ',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_EVENT);
              END IF;

              l_conv_type := 'EMU Fixed';
              l_conv_rate := gl_currency_api.get_closest_rate
                            (x_from_currency    => l.currency_code
                            ,x_to_currency      => l_mrc_ledger.ledger_currency
                            ,x_conversion_date  => l_conv_date
                            ,x_conversion_type  => l_conv_type
                            ,x_max_roll_days    => l_mrc_ledger.max_roll_days);

            ELSIF (l.currency_conversion_type = 'User') THEN
              IF (l.primary_type IN ('EMU', 'EURO') AND l.from_type IN ('EMU', 'EURO')) THEN

                IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace(p_msg    => ' case 2 ',
                        p_module => l_log_module,
                        p_level  => C_LEVEL_EVENT);
                END IF;

                l_conv_type := l_mrc_ledger.alc_default_conv_rate_type;
                l_conv_rate := gl_currency_api.get_closest_rate
                            (x_from_currency    => l.currency_code
                            ,x_to_currency      => l_mrc_ledger.ledger_currency
                            ,x_conversion_date  => l_conv_date
                            ,x_conversion_type  => l_conv_type
                            ,x_max_roll_days    => l_mrc_ledger.max_roll_days);
              ELSE

                IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace(p_msg    => ' case 3 ',
                        p_module => l_log_module,
                        p_level  => C_LEVEL_EVENT);
                END IF;

                l_conv_type := 'User';
                l_conv_rate := l.currency_conversion_rate *
                           gl_currency_api.get_closest_rate
                            (x_from_currency    => l_trx_ledger_currency
                            ,x_to_currency      => l_mrc_ledger.ledger_currency
                            ,x_conversion_date  => l_conv_date
                            ,x_conversion_type  => l_mrc_ledger.alc_default_conv_rate_type
                            ,x_max_roll_days    => l_mrc_ledger.max_roll_days);
              END IF;
            ELSE

              IF (l_mrc_ledger.alc_inherit_conversion_type = 'Y' and l.currency_conversion_type IS NOT NULL) THEN

                IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace(p_msg    => ' case 4 ',
                        p_module => l_log_module,
                        p_level  => C_LEVEL_EVENT);
                END IF;

                l_conv_type := l.currency_conversion_type;
                l_conv_rate := gl_currency_api.get_closest_rate
                            (x_from_currency    => l.currency_code
                            ,x_to_currency      => l_mrc_ledger.ledger_currency
                            ,x_conversion_date  => l_conv_date
                            ,x_conversion_type  => l_conv_type
                            ,x_max_roll_days    => l_mrc_ledger.max_roll_days);
              ELSE

                IF (C_LEVEL_EVENT >= g_log_level) THEN
                  trace(p_msg    => ' case 5 ',
                        p_module => l_log_module,
                        p_level  => C_LEVEL_EVENT);
                END IF;

                l_conv_type := l_mrc_ledger.alc_default_conv_rate_type;
                l_conv_rate := gl_currency_api.get_closest_rate
                            (x_from_currency    => l.currency_code
                            ,x_to_currency      => l_mrc_ledger.ledger_currency
                            ,x_conversion_date  => l_conv_date
                            ,x_conversion_type  => l_conv_type
                            ,x_max_roll_days    => l_mrc_ledger.max_roll_days);
              END IF;
            END IF;

            IF (C_LEVEL_EVENT >= g_log_level) THEN
              trace(p_msg    => '  return: l_conv_type = '||l_conv_type||', l_conv_rate = '||l_conv_rate,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_EVENT);
            END IF;

          EXCEPTION
            WHEN gl_currency_api.NO_RATE THEN
              p_status_codes(i) := C_AE_STATUS_INVALID;
              l_retcode := C_COMPLETION_FAILED;
              l_conv_rate := NULL;

              xla_accounting_err_pkg.build_message(
                     p_appli_s_name         => 'XLA'
                    ,p_msg_name             => 'XLA_MJE_MRC_NO_RATE'
                    ,p_token_1              => 'ALC_LEDGER'
                    ,p_value_1              => l_mrc_ledger.ledger_name
                    ,p_token_2              => 'LEDGER'
                    ,p_value_2              => l_trx_ledger_name
                    ,p_token_3              => 'CURRENCY_CODE'
                    ,p_value_3              => l.currency_code
                    ,p_token_4              => 'CONVERSION_DATE'
                    ,p_value_4              => l.currency_conversion_date
                    ,p_entity_id            => p_info.entity_id
                    ,p_event_id             => p_info.event_id
                    ,P_LEDGER_id            => l_mrc_ledger.ledger_id
                    ,p_ae_header_id         => p_ae_header_ids(i)
                    ,p_ae_line_num          => l.displayed_line_number
                    ,p_accounting_batch_id  => p_info.accounting_batch_id);
          END;

        END IF;
      END IF;

      IF(l_trx_ledger_currency = l_mrc_ledger.ledger_currency ) THEN
        l_accounted_cr := l.accounted_cr;
        l_accounted_dr := l.accounted_dr;
      ELSE
        l_accounted_cr := round_currency(l.unrounded_entered_cr * l_conv_rate,
                                    l_mrc_ledger.ledger_currency, l_trx_rounding_rule); -- accounted cr
        l_accounted_dr := round_currency(l.unrounded_entered_dr * l_conv_rate,
                                    l_mrc_ledger.ledger_currency, l_trx_rounding_rule); -- accounted dr
      END IF;

      --
      -- Create journal entry lines for the mrc entry
      --
      INSERT INTO xla_ae_lines
       		(ae_header_id
       		,ae_line_num
                ,displayed_line_number
       		,application_id
       		,code_combination_id
       		,gl_transfer_mode_code
       		,accounting_class_code
       		,creation_date
       		,created_by
       		,last_update_date
       		,last_updated_by
       		,last_update_login
       		,party_id
       		,party_site_id
       		,party_type_code
       		,entered_dr
       		,entered_cr
       		,accounted_dr
       		,accounted_cr
                ,unrounded_entered_dr
                ,unrounded_entered_cr
       		,unrounded_accounted_dr
   	        ,unrounded_accounted_cr
      		,description
       		,statistical_amount
       		,currency_code
       		,currency_conversion_type
       		,currency_conversion_date
       		,currency_conversion_rate
       		,jgzz_recon_ref
       		,ussgl_transaction_code
                ,gl_sl_link_table
       		,attribute_category
                ,encumbrance_type_id
       		,attribute1
       		,attribute2
       		,attribute3
       		,attribute4
       		,attribute5
       		,attribute6
       		,attribute7
       		,attribute8
       		,attribute9
       		,attribute10
       		,attribute11
       		,attribute12
       		,attribute13
       		,attribute14
       		,attribute15
            ,gain_or_loss_flag
            ,ledger_id
            ,accounting_date
            ,mpa_accrual_entry_flag)  -- 4262811
      VALUES
       		(p_ae_header_ids(i)
       		,l.ae_line_num
                ,l.displayed_line_number
       		,p_info.application_id
       		,l.code_combination_id
       		,l.gl_transfer_mode_code
       		,l.accounting_class_code
       		,sysdate
       		,l_last_updated_by
       		,sysdate
       		,l_last_updated_by
       		,l_last_update_login
       		,l.party_id
       		,l.party_site_id
       		,l.party_type_code
       		,l.entered_dr
       		,l.entered_cr
                ,l_accounted_dr
                ,l_accounted_cr
                ,l.unrounded_entered_dr               -- unrounded entered dr
                ,l.unrounded_entered_cr               -- unrounded entered cr
                ,DECODE(l_trx_ledger_currency,l_mrc_ledger.ledger_currency
                       ,l.unrounded_accounted_dr,l.unrounded_entered_dr * l_conv_rate) -- unrounded accounted dr
                ,DECODE(l_trx_ledger_currency,l_mrc_ledger.ledger_currency
                       ,l.unrounded_accounted_cr,l.unrounded_entered_cr * l_conv_rate) -- unrounded accounted cr
                ,l.description
       	        ,l.statistical_amount
      	        ,l.currency_code
       	        ,decode(l.currency_code, l_mrc_ledger.ledger_currency, NULL, l_conv_type)
       	        ,decode(l.currency_code, l_mrc_ledger.ledger_currency, NULL, l_conv_date)
       	        ,decode(l.currency_code, l_mrc_ledger.ledger_currency, NULL, l_conv_rate)
       	        ,l.jgzz_recon_ref
       	        ,l.ussgl_transaction_code
                ,'XLAJEL'
       	        ,l.attribute_category
     	        ,l.encumbrance_type_id
       	        ,l.attribute1
       	        ,l.attribute2
       	        ,l.attribute3
       	        ,l.attribute4
       	        ,l.attribute5
       	        ,l.attribute6
       	        ,l.attribute7
       	        ,l.attribute8
       	        ,l.attribute9
       	        ,l.attribute10
       	        ,l.attribute11
       	        ,l.attribute12
       	        ,l.attribute13
       	        ,l.attribute14
       	        ,l.attribute15
                ,l.gain_or_loss_flag
     	        ,l_mrc_ledger.ledger_id
                ,p_info.gl_date
                ,NVL(l.mpa_accrual_entry_flag,'N'));     -- 4262811 mpa_accrual_entry_flag

       --
       -- Populate distribution links
       --
       IF NOT is_reversal
                (p_application_id => p_info.application_id
                ,p_ae_header_id   => p_info.header_id
                ,p_temp_line_num  => l.ae_line_num)
       THEN

          create_distribution_link
            (p_application_id    => p_info.application_id
            ,p_ae_header_id      => p_ae_header_ids(i)
            ,p_ae_line_num       => l.ae_line_num
            ,p_temp_line_num     => l.ae_line_num
            ,p_ref_ae_header_id  => p_ae_header_ids(i)
            ,p_ref_event_id      => NULL
            ,p_ref_temp_line_num => NULL);

       ELSE

          l_temp_line_num := l.ae_line_num;
          --
          -- When reversal entries are updated
          -- create_mrc_entries is called insted of create_mrc_reversal_entry
          -- because it is not a 'Reversal' event.
          -- Mrc entries are deleted when draft entries are updated
          -- Therefore, need to retrieve reference information for mrc entries
          -- again.
          --
          get_mrc_rev_line_info
            (p_application_id    => p_info.application_id
            ,p_ae_header_id      => p_info.header_id
            ,p_temp_line_num     => l_temp_line_num  -- IN OUT
            ,p_ref_ae_header_id  => l_ref_ae_header_id
            ,p_ref_temp_line_num => l_ref_temp_line_num
            ,p_ref_event_id      => l_ref_event_id);

          create_distribution_link
            (p_application_id    => p_info.application_id
            ,p_ae_header_id      => p_ae_header_ids(i)
            ,p_ae_line_num       => l.ae_line_num
            ,p_temp_line_num     => l_temp_line_num
            ,p_ref_ae_header_id  => l_ref_ae_header_id
            ,p_ref_event_id      => l_ref_event_id
            ,p_ref_temp_line_num => l_ref_temp_line_num);

       END IF;

    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - copy lines',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    --
    -- Copy the journal entry lines' analytical criteria from the original entry to
    -- the mrc entry
    --
    INSERT INTO xla_ae_line_acs (
           ae_header_id
          ,ae_line_num
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,object_version_number)
    SELECT p_ae_header_ids(i)
          ,ae_line_num
          ,analytical_criterion_code
          ,analytical_criterion_type_code
          ,amb_context_code
          ,ac1
          ,ac2
          ,ac3
          ,ac4
          ,ac5
          ,1
      FROM xla_ae_line_acs
     WHERE ae_header_id = p_info.header_id;

  END LOOP;

  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - mrc ledgers',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure create_mrc_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  IF (c_mrc_ledgers%ISOPEN) THEN
    CLOSE c_mrc_ledgers;
  END IF;

  RAISE;
WHEN OTHERS                                   THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  IF (c_mrc_ledgers%ISOPEN) THEN
    CLOSE c_mrc_ledgers;
  END IF;

  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.create_mrc_entries');

END create_mrc_entries;


--=============================================================================
--
-- Name: delete_mrc_entries
-- Description: Delete MRC entries for a journal entry.
--
--=============================================================================
PROCEDURE delete_mrc_entries
  (p_event_id		IN  INTEGER
  ,p_application_id	IN  INTEGER
  ,p_ledger_id		IN  INTEGER)
IS

  CURSOR c_entries IS
    SELECT h.ae_header_id
      FROM xla_ae_headers h
         , xla_ledger_relationships_v l
     WHERE h.event_id          = p_event_id
       AND h.application_id    = p_application_id
       AND h.ledger_id        = l.ledger_id
       AND  (l.LEDGER_CATEGORY_CODE IN ('ALC','SECONDARY')
       OR   (l.LEDGER_CATEGORY_CODE= 'PRIMARY' AND h.parent_ae_header_id IS NOT NULL));
  -- change for AT and T 8736946

  i		INTEGER := 0;
  j		INTEGER := 0;
  l_header_ids	t_array_int;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_mrc_entries';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_mrc_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '    p_event_id       = '||p_event_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => '    p_application_id = '||p_application_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
    trace(p_msg    => '    p_ledger_id      = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - delete mrc entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_entry IN c_entries LOOP
    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP - delete MRC entry: ae_header_id = '||l_entry.ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    i := i+1;
    l_header_ids(i) := l_entry.ae_header_id;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - delete mrc entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FORALL j in 1..i
    DELETE FROM xla_ae_line_acs
      WHERE ae_header_id = l_header_ids(j);

  FORALL j in 1..i
    DELETE FROM xla_ae_header_acs
      WHERE ae_header_id = l_header_ids(j);

  FORALL j IN 1..i
    DELETE xla_distribution_links
     WHERE ae_header_id   = l_header_ids(j)
       AND application_id = p_application_id;

  FORALL j in 1..i
    DELETE FROM xla_ae_segment_values
      WHERE ae_header_id = l_header_ids(j);

  FORALL j in 1..i
    DELETE FROM xla_ae_lines
      WHERE ae_header_id = l_header_ids(j)
	AND application_id = p_application_id;

  FORALL j in 1..i
    DELETE xla_ae_headers
      WHERE ae_header_id = l_header_ids(j)
	AND application_id = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_mrc_entries',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  IF (c_entries%ISOPEN) THEN
    CLOSE c_entries;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  IF (c_entries%ISOPEN) THEN
    CLOSE c_entries;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.delete_mrc_entries');
END delete_mrc_entries;

--=============================================================================
--
-- Name: transfer_to_gl
-- Description: If the completion option is Transfer or Transfer and Post,
--              issue Transfer to GL program.
--
--=============================================================================
PROCEDURE transfer_to_gl
 (p_info                  IN t_je_info
 ,p_application_id        IN INTEGER
 ,p_completion_option     IN VARCHAR2
 ,p_transfer_request_id   IN OUT NOCOPY INTEGER)
IS
  l_accounting_batch_id    INTEGER;
  l_transfer_errbuf 	   VARCHAR2(30);
  l_transfer_retcode	   NUMBER;
  l_event_source_info      xla_events_pub_pkg.t_event_source_info;

  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.transfer_to_gl';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure transfer_to_gl',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_info.type_code <> C_TYPE_UPGRADE AND
      p_completion_option in (C_COMPLETION_OPTION_TRANSFER,
                              C_COMPLETION_OPTION_POST)) THEN

    IF (p_completion_option = C_COMPLETION_OPTION_TRANSFER) THEN
      -- Transfer to GL
      l_event_source_info.application_id := p_application_id;
      xla_accounting_pub_pkg.accounting_program_document
    	  (p_event_source_info 		=> l_event_source_info
    	  ,p_entity_id         		=> p_info.entity_id
    	  ,p_accounting_flag   		=> 'N'
    	  ,p_accounting_mode   		=> NULL
    	  ,p_transfer_flag     		=> 'Y'
    	  ,p_gl_posting_flag   		=> 'N'
    	  ,p_offline_flag     		=> 'Y'
    	  ,p_accounting_batch_id	=> l_accounting_batch_id
    	  ,p_errbuf  			=> l_transfer_errbuf
    	  ,p_retcode  			=> l_transfer_retcode
    	  ,p_request_id       		=> p_transfer_request_id);

    ELSE
      -- Transfer and post to GL
      l_event_source_info.application_id := p_application_id;
      xla_accounting_pub_pkg.accounting_program_document
    	  (p_event_source_info 		=> l_event_source_info
    	  ,p_entity_id         		=> p_info.entity_id
    	  ,p_accounting_flag   		=> 'N'
    	  ,p_accounting_mode   		=> NULL
    	  ,p_transfer_flag     		=> 'Y'
    	  ,p_gl_posting_flag   		=> 'Y'
    	  ,p_offline_flag     		=> 'Y'
    	  ,p_accounting_batch_id	=> l_accounting_batch_id
    	  ,p_errbuf  			=> l_transfer_errbuf
    	  ,p_retcode  			=> l_transfer_retcode
    	  ,p_request_id       		=> p_transfer_request_id);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure transfer_to_gl',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.transfer_to_gl');
END transfer_to_gl;

--=============================================================================
--
-- Name: update_event_status
-- Description: Update the event status to Processed.
--
--=============================================================================
PROCEDURE update_event_status
 (p_info                   IN t_je_info
 ,p_completion_option      IN VARCHAR2)
IS
  l_event_source_info   xla_events_pub_pkg.t_event_source_info;
  l_event_status        VARCHAR2(30);
  l_process_status      VARCHAR2(30);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_event_status';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_event_status',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  --
  -- Update event status to 'Processed'
  --
  l_event_source_info.application_id    := p_info.application_id;
  l_event_source_info.legal_entity_id   := p_info.legal_entity_id;
  l_event_source_info.ledger_id         := p_info.ledger_id;
  l_event_source_info.entity_type_code  := C_ENTITY_TYPE_CODE_MANUAL;

  IF (p_completion_option = C_COMPLETION_OPTION_DRAFT) THEN
    l_event_status   := xla_events_pub_pkg.C_EVENT_UNPROCESSED;
    l_process_status := xla_events_pkg.C_INTERNAL_DRAFT;
  ELSE
    l_event_status   := xla_events_pub_pkg.C_EVENT_PROCESSED;
    l_process_status := xla_events_pkg.C_INTERNAL_FINAL;
  END IF;

  xla_events_pkg.update_manual_event
     		(p_event_source_info 	=> l_event_source_info
     		,p_event_id		=> p_info.event_id
     		,p_event_status_code    => l_event_status
     		,p_process_status_code	=> l_process_status);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_event_status',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.update_event_status');
END update_event_status;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION round_currency
  (p_amount         IN NUMBER
  ,p_currency_code  IN VARCHAR2
  ,p_rounding_rule_code IN VARCHAR2)
RETURN NUMBER
IS
  l_rounded_amount  NUMBER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.round_currency';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure round_currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  SELECT decode(p_rounding_rule_code
           ,'UP'
               ,ceil(p_amount/nvl(minimum_accountable_unit, power(10, -1* precision)))*
                             nvl(minimum_accountable_unit, power(10, -1* precision))
           ,'DOWN'
               ,floor(p_amount/nvl(minimum_accountable_unit, power(10, -1* precision)))*
                             nvl(minimum_accountable_unit, power(10, -1* precision))
           ,decode(minimum_accountable_unit, NULL,
                round(p_amount, precision),
                round(p_amount/minimum_accountable_unit) * minimum_accountable_unit))
  INTO   l_rounded_amount
  FROM   fnd_currencies
  WHERE  currency_code = p_currency_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'currency_code = '||p_currency_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
    trace(p_msg    => p_amount||' is converted to '||l_rounded_amount,
          p_module => l_log_module,
          p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure round_currency',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  RETURN(l_rounded_amount);
EXCEPTION

WHEN NO_DATA_FOUND 			      THEN
  RETURN (NULL);

WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.round_currency');
END round_currency;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE validate_balance_type_code
  (p_balance_type_code	IN  VARCHAR2
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_balance_type_code';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_balance_type_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_balance_type_code NOT in (C_JE_ACTUAL, C_JE_BUDGET, C_JE_ENCUMBRANCE)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_AP_INVALID_BALANCE_TYPE: '||p_balance_type_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_AP_INVALID_BALANCE_TYPE'
	 ,p_token_1		=> 'BALANCE_TYPE'
	 ,p_value_1		=> p_balance_type_code
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_balance_type_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_balance_type_code');
END validate_balance_type_code;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION validate_legal_entity_id
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_legal_entity_id  	IN  INTEGER)
RETURN INTEGER
IS
  CURSOR c IS 	SELECT	legal_entity_id
		FROM 	xle_fp_ou_ledger_v
		WHERE	legal_entity_id = p_legal_entity_id;

  l_le_id   	INTEGER;
  l_result	INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_legal_entity_id';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_legal_entity_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_legal_entity_id IS NULL) THEN
    return l_result;
  END IF;

  OPEN c;
  FETCH c INTO l_le_id;
  CLOSE c;

  IF (l_le_id IS NULL) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_LEGAL_ENT_ID: '||p_legal_entity_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_LEGAL_ENT_ID'
	,p_token_1		=> 'LEGAL_ENTITY_ID'
	,p_value_1		=> p_legal_entity_id
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    l_result := 1;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_legal_entity_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_legal_entity_id');
END validate_legal_entity_id;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION validate_line_counts
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_application_id  	IN  INTEGER
  ,p_balance_type_code  IN  VARCHAR2)
RETURN INTEGER
IS
  CURSOR c IS   SELECT    nvl(sum(nvl(accounted_dr,0)),0)
                        , nvl(sum(nvl(accounted_cr,0)),1)
                        , nvl(sum(CASE WHEN accounted_dr IS NULL THEN 0 ELSE 1 end),0)
                        , nvl(sum(CASE WHEN accounted_cr IS NULL THEN 0 ELSE 1 end),0)
                        , nvl(sum(CASE WHEN currency_code = 'STAT' THEN 1 ELSE 0 end),0)
                FROM      xla_ae_lines
                WHERE     application_id = p_application_id
                AND       ae_header_id = p_ae_header_id;

  l_total_acct_dr       NUMBER := 0;
  l_total_acct_cr       NUMBER := 0;
  l_num_dr              INTEGER := 0;
  l_num_cr              INTEGER := 0;
  l_num_stat            INTEGER := 0;
  l_result	        INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_line_counts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_line_counts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_total_acct_dr, l_total_acct_cr, l_num_dr, l_num_cr, l_num_stat;
  CLOSE c;

  IF (l_num_stat>0) THEN
    IF (p_balance_type_code <> 'A') THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_INVALID_STAT_ENTRY_TYP',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_STAT_ENTRY_TYP'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
      l_result := 1;
    END IF;
  ELSIF (p_balance_type_code = 'B') THEN
    IF (l_num_dr+l_num_cr<=0) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_INVALID_NUM_LINES_BUDG',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_NUM_LINES_BUDG'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
      l_result := 1;
    END IF;
  ELSIF (p_balance_type_code = 'E') THEN
    IF (l_num_dr+l_num_cr<=0) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_INVALID_NUM_LINES_ENC',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_NUM_LINES_ENC'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
      l_result := 1;
    END IF;
  ELSE
    /* krsankar - Added (l_total_acct_dr +l_total_acct_cr > 0) condition additionally to exclude any 0 amount lines for a single sided entry */
     IF (l_total_acct_dr +l_total_acct_cr > 0) AND (l_num_dr<=0 or l_num_cr<=0) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_INVALID_NUM_LINES',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_INVALID_NUM_LINES'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
      l_result := 1;
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_line_counts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;
WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_line_counts');
END validate_line_counts;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION validate_description
  (p_entity_id		IN  INTEGER
  ,p_event_id		IN  INTEGER
  ,p_ledger_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_description  	IN  VARCHAR2)
RETURN INTEGER
IS
  l_result	        INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_description';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_description',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (length(trim(p_description)) = 0 or p_description IS NULL) THEN
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Error: XLA_MJE_NO_DESCRIPTION',
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_accounting_err_pkg.build_message(
         p_appli_s_name         => 'XLA'
        ,p_msg_name             => 'XLA_MJE_NO_DESCRIPTION'
        ,p_entity_id            => p_entity_id
        ,p_event_id             => p_event_id
        ,p_ledger_id            => p_ledger_id
        ,p_ae_header_id         => p_ae_header_id
        ,p_ae_line_num          => NULL
        ,p_accounting_batch_id  => NULL);
    l_result := 1;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_description',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_description');
END validate_description;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE validate_delete_mode
  (p_status_code	IN  VARCHAR2
  ,p_mode 		IN  VARCHAR2
  ,p_msg_mode		IN  VARCHAR2)
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_delete_mode';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_delete_mode',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_mode NOT in (C_DELETE_NORMAL_MODE, C_DELETE_FORCE_MODE)) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_DELETE_MODE',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_DELETE_MODE'
	 ,p_msg_mode		=> p_msg_mode);
  ELSIF (p_status_code = C_AE_STATUS_FINAL AND
         p_mode <> C_DELETE_FORCE_MODE) THEN
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'Error: XLA_MJE_INVALID_DELETE_FINAL',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_DELETE_FINAL'
	 ,p_msg_mode		=> p_msg_mode);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_delete_mode',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_delete_mode');
END validate_delete_mode;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION clear_errors
  (p_event_id		IN  INTEGER
  ,p_ae_header_id	IN  INTEGER
  ,p_ae_line_num	IN  INTEGER)
RETURN BOOLEAN
IS
  CURSOR c IS
  	SELECT	ae_header_id
	FROM	xla_accounting_errors
	WHERE	ae_header_id = p_ae_header_id
  	  AND	ROWNUM = 1;
  l_exists              INTEGER;
  l_retcode             BOOLEAN := TRUE;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.clear_errors';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure clear_errors',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_accounting_errors
	WHERE	ae_header_id = p_ae_header_id
	  AND	event_id = p_event_id
          AND	nvl(ae_line_num,-1)  = nvl(p_ae_line_num,-1);

  OPEN c;
  FETCH c INTO l_exists;
  IF (c%FOUND) THEN
    l_retcode := FALSE;
  END IF;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure clear_errors',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS                                   THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.clear_errors');
END clear_errors;

--=============================================================================
--
--
--
--=============================================================================
/*
FUNCTION unreserve_funds
  (p_ae_header_id      	IN  INTEGER
  ,p_application_id    	IN  INTEGER
  ,p_ledger_id         	IN  INTEGER
  ,p_packet_id         	IN  INTEGER
  ,p_msg_mode		IN  VARCHAR2	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE)
RETURN BOOLEAN
IS
  l_funds_retcode	VARCHAR2(30);
  l_retcode		BOOLEAN := TRUE;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.unreserve_funds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure unreserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_funds_retcode := xla_je_funds_checker_pkg.unreserve_funds(
			p_ae_header_id		=> p_ae_header_id,
			p_application_id 	=> p_application_id,
			p_ledger_id		=> p_ledger_id,
			p_packet_id		=> p_packet_id);

  IF (l_funds_retcode NOT in (C_FUNDS_SUCCESS, C_FUNDS_ADVISORY)) THEN
    l_retcode := FALSE;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure unreserve_funds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.unreserve_funds');
END unreserve_funds;
*/


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_ledger_info
  (p_ledger_id			IN  INTEGER
  ,p_application_id	        IN  INTEGER
  ,p_code_combination_id	IN  INTEGER
  ,p_funct_curr			OUT NOCOPY VARCHAR2
  ,p_rounding_rule_code		OUT NOCOPY VARCHAR2
  ,p_bal_seg_val		OUT NOCOPY VARCHAR2
  ,p_mgt_seg_val		OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
    SELECT	gl.currency_code,
		xlo.rounding_rule_code,
		DECODE(gl.bal_seg_column_name, 	'SEGMENT1', ccid.segment1,
						'SEGMENT2', ccid.segment2,
						'SEGMENT3', ccid.segment3,
						'SEGMENT4', ccid.segment4,
						'SEGMENT5', ccid.segment5,
						'SEGMENT6', ccid.segment6,
						'SEGMENT7', ccid.segment7,
						'SEGMENT8', ccid.segment8,
						'SEGMENT9', ccid.segment9,
						'SEGMENT10', ccid.segment10,
					 	'SEGMENT11', ccid.segment11,
						'SEGMENT12', ccid.segment12,
						'SEGMENT13', ccid.segment13,
						'SEGMENT14', ccid.segment14,
						'SEGMENT15', ccid.segment15,
						'SEGMENT16', ccid.segment16,
						'SEGMENT17', ccid.segment17,
						'SEGMENT18', ccid.segment18,
						'SEGMENT19', ccid.segment19,
						'SEGMENT20', ccid.segment20,
					 	'SEGMENT21', ccid.segment21,
						'SEGMENT22', ccid.segment22,
						'SEGMENT23', ccid.segment23,
						'SEGMENT24', ccid.segment24,
						'SEGMENT25', ccid.segment25,
						'SEGMENT26', ccid.segment26,
						'SEGMENT27', ccid.segment27,
						'SEGMENT28', ccid.segment28,
						'SEGMENT29', ccid.segment29,
						'SEGMENT30', ccid.segment30),
		DECODE(gl.mgt_seg_column_name, 	'SEGMENT1', ccid.segment1,
						'SEGMENT2', ccid.segment2,
						'SEGMENT3', ccid.segment3,
						'SEGMENT4', ccid.segment4,
						'SEGMENT5', ccid.segment5,
						'SEGMENT6', ccid.segment6,
						'SEGMENT7', ccid.segment7,
						'SEGMENT8', ccid.segment8,
						'SEGMENT9', ccid.segment9,
						'SEGMENT10', ccid.segment10,
					 	'SEGMENT11', ccid.segment11,
						'SEGMENT12', ccid.segment12,
						'SEGMENT13', ccid.segment13,
						'SEGMENT14', ccid.segment14,
						'SEGMENT15', ccid.segment15,
						'SEGMENT16', ccid.segment16,
						'SEGMENT17', ccid.segment17,
						'SEGMENT18', ccid.segment18,
						'SEGMENT19', ccid.segment19,
						'SEGMENT20', ccid.segment20,
					 	'SEGMENT21', ccid.segment21,
						'SEGMENT22', ccid.segment22,
						'SEGMENT23', ccid.segment23,
						'SEGMENT24', ccid.segment24,
						'SEGMENT25', ccid.segment25,
						'SEGMENT26', ccid.segment26,
						'SEGMENT27', ccid.segment27,
						'SEGMENT28', ccid.segment28,
						'SEGMENT29', ccid.segment29,
						'SEGMENT30', ccid.segment30)
    FROM	gl_ledgers 	gl,
		gl_code_combinations 	ccid,
		xla_ledger_options     xlo
    WHERE	ccid.code_combination_id	= p_code_combination_id
      AND       gl.ledger_id                    = p_ledger_id
      AND       xlo.ledger_id                = p_ledger_id
      AND       xlo.application_id           = p_application_id
      ;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_ledger_info';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_ledger_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO p_funct_curr, p_rounding_rule_code, p_bal_seg_val, p_mgt_seg_val;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_ledger_info',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;
WHEN OTHERS					THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg. get_ledger_info');
END get_ledger_info;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE get_ledger_options
  (p_application_id            IN INTEGER
  ,p_ledger_id                 IN INTEGER
  ,p_transfer_to_gl_mode_code  OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
    SELECT decode(transfer_to_gl_mode_code,'D','D','S')
      FROM xla_ledger_options
     WHERE application_id = p_application_id
       AND ledger_id      = p_ledger_id;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_ledger_options';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_ledger_options',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO p_transfer_to_gl_mode_code;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_ledger_options',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;
WHEN OTHERS                                     THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg. get_ledger_options');
END get_ledger_options;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE update_segment_values
  (p_ae_header_id		IN  INTEGER
  ,p_seg_type			IN  VARCHAR2
  ,p_seg_value			IN  VARCHAR2
  ,p_action			IN  VARCHAR2)
IS
  CURSOR c_seg IS
    SELECT	ae_lines_count
    FROM	xla_ae_segment_values
    WHERE	segment_type_code = p_seg_type
      AND	ae_header_id = p_ae_header_id
      AND	segment_value = p_seg_value;

  l_seg_count           INTEGER;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_segment_values';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_segment_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c_seg;
  FETCH c_seg INTO l_seg_count;
  CLOSE c_seg;

  IF (p_action = C_ACTION_DEL) THEN
    IF (l_seg_count = 1) THEN
      DELETE xla_ae_segment_values
       WHERE ae_header_id = p_ae_header_id
         AND segment_type_code = p_seg_type
         AND segment_value = p_seg_value;
    ELSE
      UPDATE xla_ae_segment_values
         SET ae_lines_count = ae_lines_count - 1
       WHERE ae_header_id = p_ae_header_id
         AND segment_type_code = p_seg_type
         AND segment_value = p_seg_value;
    END IF;

  ELSIF(p_action = C_ACTION_ADD) THEN
    IF (l_seg_count IS NULL) THEN
      INSERT INTO xla_ae_segment_values(ae_header_id, segment_type_code, segment_value, ae_lines_count)
   	VALUES(p_ae_header_id, p_seg_type, p_seg_value, 1);
    ELSE
      UPDATE xla_ae_segment_values
         SET ae_lines_count = ae_lines_count + 1
       WHERE ae_header_id = p_ae_header_id
         AND segment_type_code = p_seg_type
         AND segment_value = p_seg_value;
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure update_segment_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_seg%ISOPEN) THEN
    CLOSE c_seg;
  END IF;
  RAISE;
WHEN OTHERS					THEN
  IF (c_seg%ISOPEN) THEN
    CLOSE c_seg;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.update_segment_values');
END update_segment_values;

--=============================================================================
--
-- Name: validate_je_category
-- Description: Raise error message IF the je category is invalid
--
--=============================================================================
PROCEDURE validate_je_category
  (p_je_category_name           IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2)
IS
  CURSOR c IS
    SELECT      je_category_name
    FROM        gl_je_categories
    WHERE       je_category_name        = p_je_category_name;
  l_code        VARCHAR2(30);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_je_category';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_je_category',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_code;
  IF (c%NOTFOUND) THEN
    CLOSE c;

    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_JOURNAL_CAT'
	 ,p_token_1		=> 'JE_CATEGORY'
	 ,p_value_1		=> p_je_category_name
	 ,p_msg_mode		=> p_msg_mode);
  END IF;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_je_category',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_je_category');
END validate_je_category;

--============================================================================
--
-- Name: validate_application_id
-- Description: Raise error message if the application id is invalid
--
--=============================================================================
PROCEDURE validate_application_id
  (p_application_id     IN  INTEGER)
IS
  CURSOR c IS
    SELECT      application_id
    FROM        xla_subledgers
    WHERE       application_id = p_application_id;
  l_app_id      INTEGER;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_application_id';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_application_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_app_id;
  IF (c%NOTFOUND) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_APP_ID'
	 ,p_token_1		=> 'APPLICATION_ID'
	 ,p_value_1		=> p_application_id);
  END IF;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_application_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
    (p_location => 'xla_journal_entries_pkg.validate_application_id');
END validate_application_id;

--=============================================================================
--
-- Name: validate_ledger
-- Description: Raise error message if the ledger id is invalid, or, for
--              budget AND encumbrance journal entry, the ledger type is not
--              primary or alternative currency ledgers.
--
--=============================================================================
PROCEDURE validate_ledger
  (p_ledger_id                  IN  INTEGER
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budgetary_control_flag     IN  VARCHAR2)
IS
  CURSOR c IS
    SELECT      name, ledger_category_code, latest_encumbrance_year, enable_budgetary_control_flag
    FROM        gl_ledgers
    WHERE       ledger_id = p_ledger_id;

  l_ledger_name                 gl_ledgers.name%TYPE;
  l_classification_code         gl_ledgers.ledger_category_code%TYPE;
  l_latest_encumbrance_year     gl_ledgers.latest_encumbrance_year%TYPE;
  l_bc_enabled_flag             gl_ledgers.enable_budgetary_control_flag%TYPE;
  l_log_module                  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_ledger';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_ledger',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO l_ledger_name, l_classification_code, l_latest_encumbrance_year, l_bc_enabled_flag;

  IF (c%NOTFOUND) THEN
    xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_LEDGER_ID'
	 ,p_token_1		=> 'LEDGER_ID'
	 ,p_value_1		=> p_ledger_id);
  ELSE
    IF (p_balance_type_code in (C_JE_BUDGET, C_JE_ENCUMBRANCE) AND
         l_classification_code NOT in ('PRIMARY', 'ALC_TRANSACTION')) THEN
      xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_LEDGER_ASSGN'
	 ,p_token_1		=> 'LEDGER_NAME'
	 ,p_value_1		=> l_ledger_name);
    END IF;

    IF (p_balance_type_code = C_JE_ENCUMBRANCE AND
        l_latest_encumbrance_year IS NULL) THEN
      xla_exceptions_pkg.raise_message
	 (p_appli_s_name	=> 'XLA'
         ,p_msg_name		=> 'XLA_MJE_INVALID_ENCUM_LEDGER'
	 ,p_token_1		=> 'LEDGER_NAME'
	 ,p_value_1		=> l_ledger_name);
    END IF;

    IF (p_budgetary_control_flag = 'Y' AND l_bc_enabled_flag = 'N') THEN
            xla_exceptions_pkg.raise_message
         (p_appli_s_name        => 'XLA'
         ,p_msg_name            => 'XLA_MJE_INVALID_BC_LEDGER'
         ,p_token_1             => 'LEDGER_NAME'
         ,p_value_1             => l_ledger_name);
    END IF;
  END IF;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_ledger',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_ledger');
end validate_ledger;

--=============================================================================
--
-- Name: validate_amounts
-- Description: This API calculates the accounted amount.
--
--=============================================================================
FUNCTION validate_amounts
  (p_entity_id                  IN  INTEGER
  ,p_event_id                   IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_application_id		IN  INTEGER
  ,p_functional_curr		IN  VARCHAR2)
RETURN INTEGER
IS
  CURSOR c_lines IS
    SELECT ae_line_num
          ,entered_dr
          ,entered_cr
          ,currency_code
          ,accounted_dr
          ,accounted_cr
          ,currency_conversion_type conv_type
          ,currency_conversion_date conv_date
          ,currency_conversion_rate conv_rate
      FROM xla_ae_lines
     WHERE ae_header_id = p_ae_header_id
       AND application_id = p_application_id
       AND gain_or_loss_flag = 'N';

  l_result			INTEGER := 0;
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_amounts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - validate amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_line IN c_lines LOOP
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'LOOP validate amounts: ae_line_num = '||l_line.ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
    END IF;

    l_line.currency_code := nvl(l_line.currency_code, p_functional_curr);

    IF ((l_line.accounted_dr IS NULL AND l_line.entered_dr IS NOT NULL) OR
         (l_line.accounted_cr IS NULL AND l_line.entered_cr IS NOT NULL) )
    THEN
      IF (l_line.currency_code <> p_functional_curr) THEN
        IF (l_line.conv_date IS NULL) THEN
          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'Error: XLA_AP_NO_CONV_DATE',
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
          END IF;

          xla_accounting_err_pkg.build_message(
             p_appli_s_name             => 'XLA'
            ,p_msg_name                 => 'XLA_AP_NO_CONV_DATE'
            ,p_token_1                  => 'LINE_NUM'
            ,p_value_1                  => l_line.ae_line_num
            ,p_entity_id                => p_entity_id
            ,p_event_id                 => p_event_id
            ,p_ledger_id                => p_ledger_id
            ,p_ae_header_id             => p_ae_header_id
            ,p_ae_line_num              => l_line.ae_line_num
            ,p_accounting_batch_id      => NULL);
          l_result := 1;
      	END IF;

        IF (l_line.conv_type IS NULL) THEN
          IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace(p_msg    => 'Error: XLA_AP_NO_CONV_TYPE',
                  p_module => l_log_module,
                  p_level  => C_LEVEL_ERROR);
          END IF;

          xla_accounting_err_pkg.build_message(
           p_appli_s_name               => 'XLA'
          ,p_msg_name                   => 'XLA_AP_NO_CONV_TYPE'
          ,p_token_1                    => 'LINE_NUM'
          ,p_value_1                    => l_line.ae_line_num
          ,p_entity_id                  => p_entity_id
          ,p_event_id                   => p_event_id
          ,p_ledger_id                  => p_ledger_id
          ,p_ae_header_id               => p_ae_header_id
          ,p_ae_line_num                => l_line.ae_line_num
          ,p_accounting_batch_id        => NULL);
          l_result := 1;
        ELSIF (l_line.conv_type = 'User') THEN
          IF (l_line.conv_rate IS NULL) THEN
            IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace(p_msg    => 'Error: XLA_AP_NO_USER_CONV_RATE',
                    p_module => l_log_module,
                    p_level  => C_LEVEL_ERROR);
            END IF;

            xla_accounting_err_pkg.build_message(
           	p_appli_s_name               => 'XLA'
          	,p_msg_name                  => 'XLA_AP_NO_USER_CONV_RATE'
          	,p_token_1                   => 'LINE_NUM'
          	,p_value_1                   => l_line.ae_line_num
          	,p_entity_id                 => p_entity_id
          	,p_event_id                  => p_event_id
          	,p_ledger_id                 => p_ledger_id
          	,p_ae_header_id              => p_ae_header_id
          	,p_ae_line_num               => l_line.ae_line_num
          	,p_accounting_batch_id       => NULL);
          	l_result := 1;
            l_line.accounted_cr := l_line.entered_cr;
            l_line.accounted_dr := l_line.entered_dr;
          ELSE
            IF (l_line.entered_cr IS NOT NULL) THEN
              l_line.accounted_cr := l_line.entered_cr * l_line.conv_rate;
            END IF;
            IF (l_line.entered_dr IS NOT NULL) THEN
              l_line.accounted_dr := l_line.entered_dr * l_line.conv_rate;
            END IF;
          END IF;
        ELSE	-- l_conv_type <> 'User'
          begin
            l_line.conv_rate := gl_currency_api.get_rate(
             	 x_from_currency        => l_line.currency_code
            	,x_to_currency          => p_functional_curr
            	,x_conversion_date      => l_line.conv_date
            	,x_conversion_type      => l_line.conv_type);
          exception
            WHEN gl_currency_api.NO_RATE THEN
              IF (C_LEVEL_ERROR >= g_log_level) THEN
                trace(p_msg    => 'Error: XLA_AP_NO_CONV_RATE',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_ERROR);
              END IF;

              xla_accounting_err_pkg.build_message(
               	 p_appli_s_name             => 'XLA'
              	,p_msg_name                 => 'XLA_AP_NO_CONV_RATE'
              	,p_token_1                  => 'CURRENCY_CODE'
              	,p_value_1                  => l_line.currency_code
              	,p_token_2                  => 'CONVERSION_TYPE'
              	,p_value_2                  => l_line.conv_type
              	,p_token_3                  => 'CONVERSION_DATE'
              	,p_value_3                  => to_char(l_line.conv_date,'DD/MM/YYYY')
              	,p_token_4                  => 'LINE_NUM'
              	,p_value_4                  => p_ae_header_id
              	,p_entity_id                => p_entity_id
              	,p_event_id                 => p_event_id
              	,p_ledger_id                => p_ledger_id
              	,p_ae_header_id             => p_ae_header_id
              	,p_ae_line_num              => l_line.ae_line_num
              	,p_accounting_batch_id      => NULL);
              l_result := 1;
          end;
          IF (l_line.entered_cr IS NOT NULL) THEN
            l_line.accounted_cr := l_line.entered_cr * l_line.conv_rate;
          END IF;
          IF (l_line.entered_dr IS NOT NULL) THEN
            l_line.accounted_dr := l_line.entered_dr * l_line.conv_rate;
          END IF;
        END IF;
      ELSE
        l_line.accounted_dr := l_line.entered_dr;
        l_line.accounted_cr := l_line.entered_cr;
        l_line.conv_type := NULL;
        l_line.conv_rate := NULL;
        l_line.conv_date := NULL;
      END IF;
    END IF;

/* removed, not sure why we need this
    IF (l_line.entered_cr IS NOT NULL) THEN
      l_line.entered_cr := round_currency(l_line.entered_cr, l_line.currency_code);
    END IF;

    IF (l_line.accounted_cr IS NOT NULL) THEN
      l_line.accounted_cr := round_currency(l_line.accounted_cr, p_functional_curr);
    END IF;

    IF (l_line.entered_dr IS NOT NULL) THEN
      l_line.entered_dr := round_currency(l_line.entered_dr, l_line.currency_code);
    END IF;

    IF (l_line.accounted_dr IS NOT NULL) THEN
      l_line.accounted_dr := round_currency(l_line.accounted_dr, p_functional_curr);
    END IF;
*/

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - validate amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  RAISE;
WHEN OTHERS THEN
  IF (c_lines%ISOPEN) THEN
    CLOSE c_lines;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.validate_amounts');
end validate_amounts;

--=============================================================================
--
-- Name: calculate_amounts
-- Description: This API calculates the accounted amount.
--
--=============================================================================
PROCEDURE calculate_amounts
  (p_entered_dr                 IN OUT NOCOPY NUMBER
  ,p_entered_cr                 IN OUT NOCOPY NUMBER
  ,p_currency_code              IN OUT NOCOPY VARCHAR2
  ,p_functional_curr            IN VARCHAR2
  ,p_rounding_rule_code         IN VARCHAR2
  ,p_accounted_dr               IN OUT NOCOPY NUMBER
  ,p_accounted_cr               IN OUT NOCOPY NUMBER
  ,p_unrounded_entered_dr       IN OUT NOCOPY NUMBER
  ,p_unrounded_entered_cr       IN OUT NOCOPY NUMBER
  ,p_unrounded_accted_dr        IN OUT NOCOPY NUMBER
  ,p_unrounded_accted_cr        IN OUT NOCOPY NUMBER
  ,p_conv_type                  IN OUT NOCOPY VARCHAR2
  ,p_conv_date                  IN OUT NOCOPY DATE
  ,p_conv_rate                  IN OUT NOCOPY NUMBER)
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.calculate_amounts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure calculate_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  p_currency_code := nvl(p_currency_code, p_functional_curr);
  p_unrounded_entered_dr := p_entered_dr;
  p_unrounded_entered_cr := p_entered_cr;

  IF (p_accounted_dr IS NULL AND p_accounted_cr IS NULL) THEN
    IF (p_currency_code <> p_functional_curr) THEN

      IF (p_conv_type IS NULL) THEN
	p_unrounded_accted_cr := NULL;
	p_unrounded_accted_dr := NULL;

      ELSIF (p_conv_type = 'User') THEN
	IF (p_conv_rate IS NOT NULL) THEN
          IF (p_entered_cr IS NOT NULL) THEN
            p_unrounded_accted_cr := p_entered_cr * p_conv_rate;
          END IF;
          IF (p_entered_dr IS NOT NULL) THEN
            p_unrounded_accted_dr := p_entered_dr * p_conv_rate;
          END IF;
 	ELSE
	  p_unrounded_accted_cr := NULL;
	  p_unrounded_accted_dr := NULL;
        END IF;

      ELSIF (p_conv_date IS NOT NULL) THEN	-- p_conv_type is non-User
        begin
          p_conv_rate := gl_currency_api.get_rate(
             x_from_currency        => p_currency_code
            ,x_to_currency          => p_functional_curr
            ,x_conversion_date      => p_conv_date
            ,x_conversion_type      => p_conv_type);

          IF (p_entered_cr IS NOT NULL) THEN
            p_unrounded_accted_cr := p_entered_cr * p_conv_rate;
          END IF;
          IF (p_entered_dr IS NOT NULL) THEN
            p_unrounded_accted_dr := p_entered_dr * p_conv_rate;
          END IF;

        exception
          WHEN gl_currency_api.NO_RATE THEN
 	        p_conv_rate := NULL;
      		p_unrounded_accted_dr := NULL;
      		p_unrounded_accted_cr := NULL;
        end;
      ELSE  -- p_conv_type is non-User and p_conv_date IS NULL
        p_conv_rate := NULL;
      	p_unrounded_accted_dr := NULL;
      	p_unrounded_accted_cr := NULL;
      END IF;
    ELSE
      p_unrounded_accted_dr := p_entered_dr;
      p_unrounded_accted_cr := p_entered_cr;
      p_conv_type := NULL;
      p_conv_rate := NULL;
      p_conv_date := NULL;
    END IF;
  END IF;

  IF (p_entered_cr IS NOT NULL) THEN
    p_entered_cr := round_currency(p_entered_cr, p_currency_code, p_rounding_rule_code);
  END IF;

  IF (p_unrounded_accted_cr IS NOT NULL) THEN
    p_accounted_cr := round_currency(p_unrounded_accted_cr, p_functional_curr, p_rounding_rule_code);
  END IF;

  IF (p_entered_dr IS NOT NULL) THEN
    p_entered_dr := round_currency(p_entered_dr, p_currency_code, p_rounding_rule_code);
  END IF;

  IF (p_unrounded_accted_dr IS NOT NULL) THEN
    p_accounted_dr := round_currency(p_unrounded_accted_dr, p_functional_curr, p_rounding_rule_code);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure calculate_amounts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.calculate_amounts');
END calculate_amounts;


--=============================================================================
--
-- Name: get_period_name
-- Description: Retrieve the period name of an accounting date for a ledger,
--              and its status and period type.
--
--=============================================================================
FUNCTION get_period_name
  (p_ledger_id          IN  INTEGER
  ,p_accounting_date    IN  DATE
  ,p_closing_status     OUT NOCOPY VARCHAR2
  ,p_period_type        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT      closing_status, period_name, period_type
    FROM        gl_period_statuses
    WHERE       application_id          = C_GL_APPLICATION_ID
      AND       ledger_id               = p_ledger_id
      AND       adjustment_period_flag  = 'N'
      AND       p_accounting_date       BETWEEN start_date AND end_date;
  l_period_name         VARCHAR2(25);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_period_name';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function get_period_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_ledger_id = '||p_ledger_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_accounting_date = '||p_accounting_date,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  OPEN c;
  FETCH c INTO p_closing_status, l_period_name, p_period_type;
  CLOSE c;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function get_period_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_period_name;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  RAISE;

WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.get_period_name');
END get_period_name;


--=============================================================================
--
-- Name: funds_check_result
-- Description: This API creates the funds result.
--
--=============================================================================
PROCEDURE funds_check_result
  (p_packet_id                  IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_sequence_id                IN OUT NOCOPY INTEGER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_log_module          VARCHAR2(240);

  l_sequence_id         NUMBER(15);
  l_event_flag          VARCHAR2(1) := 'P';
  l_errbuf              VARCHAR2(2000);
  l_retcode             NUMBER(15);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.funds_check_result';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure funds_check_result',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE
    FROM PSA_BC_REPORT_EVENTS_GT;

  INSERT
  INTO PSA_BC_REPORT_EVENTS_GT(packet_id)
  VALUES(p_packet_id);

  SELECT PSA_BC_XML_REPORT_S.nextval
    INTO l_sequence_id
    FROM DUAL;

  -- Call XML Generation Procedure

  PSA_BC_XML_REPORT_PUB.create_bc_transaction_report
    (p_ledger_id         => p_ledger_id
    ,p_application_id    => p_application_id
    ,p_packet_event_flag => l_event_flag
    ,p_sequence_id       => l_sequence_id
    ,errbuf              => l_errbuf
    ,retcode             => l_retcode);

  p_sequence_id  := l_sequence_id;

  COMMIT;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure funds_check_result',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.funds_check_result');
END funds_check_result;



--=============================================================================
--
-- Description: This API is for datafix. Bug 5109240
--
--=============================================================================
PROCEDURE update_data
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ae_line_num                IN  INTEGER  DEFAULT NULL
  ,p_item_name                  IN  VARCHAR2
  ,p_value_varchar2             IN  VARCHAR2 DEFAULT NULL
  ,p_value_date                 IN  DATE     DEFAULT NULL
  ,p_value_number               IN  NUMBER   DEFAULT NULL
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'update_data';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode           INTEGER;
  l_log_module        VARCHAR2(240);
  l_entity_id         INTEGER   DEFAULT NULL;
  l_gl_status         VARCHAR2(2);
  l_dummy             INTEGER;

BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_data';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_data',
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
      trace(p_msg    => 'p_application_id = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_ae_header_id   = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_ae_line_num    = '||p_ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_item_name      = '||p_item_name,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_value_varchar2 = '||p_value_varchar2,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_value_date     = '||p_value_date,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
      trace(p_msg    => 'p_value_number   = '||p_value_number,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  ---------------------------------------------
  -- check that only certain items are allowed
  ---------------------------------------------
  IF NVL(p_item_name,'N') NOT IN (C_ITEM_HEADER_DESCRIPTION, C_ITEM_LINE_DESCRIPTION,
                                  C_ITEM_GL_DATE,            C_ITEM_REFERENCE_DATE,
                                  C_ITEM_ACCOUNT,            C_ITEM_ACCOUNTED_DR,   C_ITEM_ACCOUNTED_CR,
                                  C_ITEM_CURRENCY_CODE,      C_ITEM_CURR_CONV_TYPE, C_ITEM_CURR_CONV_RATE,
                                  C_ITEM_CURR_CONV_DATE,     C_ITEM_ENTERED_DR,     C_ITEM_ENTERED_CR,
                                  C_ITEM_ACCOUNTING_CLASS ) THEN
     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Item name '||p_item_name||' is incorrect or is not supported.',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
     END IF;
     xla_datafixes_pub.Log_error(p_module    => l_log_module
              ,p_error_msg => 'Item name '||p_item_name||' is incorrect or is not supported.');
  ELSE

     ------------------------------------------------
     -- check that the correct value type are passed
     ------------------------------------------------
     IF p_item_name IN    ( C_ITEM_HEADER_DESCRIPTION, C_ITEM_LINE_DESCRIPTION,  C_ITEM_CURRENCY_CODE,
                            C_ITEM_CURR_CONV_TYPE,     C_ITEM_ACCOUNTING_CLASS ) AND
                            p_value_varchar2 IS NULL THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_VARCHAR2.',
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
        END IF;
        xla_datafixes_pub.Log_error(p_module    => l_log_module
                 ,p_error_msg => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_VARCHAR2.');
     ELSIF p_item_name IN ( C_ITEM_GL_DATE, C_ITEM_REFERENCE_DATE, C_ITEM_CURR_CONV_DATE ) AND
                            p_value_date IS NULL THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_DATE.',
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
        END IF;
        xla_datafixes_pub.Log_error(p_module    => l_log_module
                 ,p_error_msg => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_DATE.');
     ELSIF p_item_name IN ( C_ITEM_ACCOUNT,        C_ITEM_ACCOUNTED_DR,   C_ITEM_ACCOUNTED_CR,
                            C_ITEM_CURR_CONV_RATE, C_ITEM_ENTERED_DR,     C_ITEM_ENTERED_CR ) AND
                            p_value_number IS NULL THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_NUMBER.',
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
        END IF;
        xla_datafixes_pub.Log_error(p_module    => l_log_module
                 ,p_error_msg => 'The value for '||p_item_name||' should be passed using parameter P_VALUE_NUMBER.');
     END IF;

  END IF;


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'entity ='||l_entity_id||'  count='||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  -------------------------------------------
  -- check that entry exists
  -------------------------------------------
  SELECT MIN(entity_id), MAX(gl_transfer_status_code)
  INTO   l_entity_id, l_gl_status
  FROM   xla_ae_headers
  WHERE  application_id = p_application_id
  AND    ae_header_id   = p_ae_header_id
  AND    accounting_entry_status_code = 'F';

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'entity ='||l_entity_id||',  gl_status='||l_gl_status||',  count='||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;

  IF l_entity_id IS NULL THEN

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'The entry does not exists or is not in Final mode.',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
     END IF;
       xla_datafixes_pub.Log_error(p_module    => l_log_module
                ,p_error_msg => 'The entry does not exists or is not in Final mode.');
  ELSE

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'Update details',
                p_module => l_log_module,
                p_level  => C_LEVEL_STATEMENT);
      END IF;

      --------------------------------------------------------------------
      -- To check that ae_line_num is valid
      --------------------------------------------------------------------
      IF p_item_name not in (C_ITEM_HEADER_DESCRIPTION, C_ITEM_REFERENCE_DATE) THEN

         IF p_ae_line_num IS NULL AND p_item_name <> C_ITEM_GL_DATE THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_msg    => 'Need ae_line_num to update '||p_item_name||'.',
                   p_module => l_log_module,
                   p_level  => C_LEVEL_STATEMENT);
            END IF;
            xla_datafixes_pub.Log_error(p_module    => l_log_module
                     ,p_error_msg => 'Need ae_line_num to update '||p_item_name||'.');

         ELSIF p_ae_line_num IS NOT NULL and p_item_name = C_ITEM_GL_DATE THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
             trace(p_msg    => 'Updating GL Date affects both headers and line number.  Ae_line_num is not required.',
                   p_module => l_log_module,
                   p_level  => C_LEVEL_STATEMENT);
            END IF;
            xla_datafixes_pub.Log_error(p_module    => l_log_module
                     ,p_error_msg => 'Updating GL Date affects both headers and line number.  Ae_line_num is not required.');

         ELSIF p_ae_line_num IS NOT NULL THEN
            -------------------------------------------
            -- check that lines exists
            -------------------------------------------
            SELECT count(*)
            INTO   l_dummy
            FROM   xla_ae_lines
            WHERE  application_id = p_application_id
            AND    ae_header_id   = p_ae_header_id
            AND    ae_line_num    = p_ae_line_num;

            IF l_dummy = 0 THEN
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Line does not exists',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
               END IF;
               xla_datafixes_pub.Log_error(p_module    => l_log_module
                        ,p_error_msg => 'Line does not exists');
            END IF;
         END IF;

      END IF;
      --
      ------------------------------------------------
      -- delete control balance
      ------------------------------------------------
      IF p_item_name IN (C_ITEM_GL_DATE,      C_ITEM_ACCOUNT
                        ,C_ITEM_ACCOUNTED_DR, C_ITEM_ACCOUNTED_CR,   C_ITEM_CURRENCY_CODE
                        ,C_ITEM_ENTERED_DR,   C_ITEM_ENTERED_CR) THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Calling xla_balances_pkg.massive_update to delete',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
         END IF;
	 IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
	    IF (NOT xla_balances_pkg.massive_update
		 (p_application_id       => p_application_id
		 ,p_ledger_id            => NULL
		 ,p_event_id             => NULL
		 ,p_entity_id            => l_entity_id
		 ,p_request_id           => NULL
		 ,p_accounting_batch_id  => NULL
		 ,p_update_mode          => 'D'         -- Delete
		 ,p_execution_mode       => 'O')) THEN  -- Online
		   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
		trace(p_msg    => 'Error from massive_update.',
		      p_module => l_log_module,
		      p_level  => C_LEVEL_STATEMENT);
		   END IF;
		   xla_datafixes_pub.Log_error(p_module    => l_log_module
		     ,p_error_msg => 'Error when deleting control balance calculation');
	    END IF;
	 ELSE
	    IF (NOT xla_balances_calc_pkg.massive_update
			 (p_application_id       => p_application_id
			 ,p_ledger_id            => NULL
			 ,p_event_id             => NULL
			 ,p_entity_id            => l_entity_id
			 ,p_request_id           => NULL
			 ,p_accounting_batch_id  => NULL
			 ,p_update_mode          => 'D'         -- Delete
			 ,p_execution_mode       => 'O')) THEN  -- Online
		IF (C_LEVEL_STATEMENT >= g_log_level) THEN
			trace(p_msg    => 'Error from massive_update.',
				  p_module => l_log_module,
				  p_level  => C_LEVEL_STATEMENT);
		END IF;
		xla_datafixes_pub.Log_error(p_module    => l_log_module
				 ,p_error_msg => 'Error when deleting control balance calculation');
	    END IF;

	 END IF;
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Returned from xla_balances_pkg.massive_update',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
         END IF;

      END IF;

      ------------------------------------------------
      -- update header details
      ------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'update header details',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
      END IF;
      IF p_item_name in (C_ITEM_HEADER_DESCRIPTION, C_ITEM_REFERENCE_DATE, C_ITEM_GL_DATE) THEN

         Update XLA_AE_HEADERS
         SET    DESCRIPTION     = DECODE(p_item_name, C_ITEM_HEADER_DESCRIPTION,    p_value_varchar2, DESCRIPTION)
               ,ACCOUNTING_DATE = DECODE(p_item_name, C_ITEM_GL_DATE,        p_value_date,     ACCOUNTING_DATE)
               ,REFERENCE_DATE  = DECODE(p_item_name, C_ITEM_REFERENCE_DATE, p_value_date,     REFERENCE_DATE)
         WHERE application_id = p_application_id
         AND   ae_header_id   = p_ae_header_id;

         xla_datafixes_pub.audit_datafix (p_application_id   => p_application_id
                       ,p_ae_header_id     => p_ae_header_id);

      END IF;

      ------------------------------------------------
      -- update line details
      ------------------------------------------------
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'update line details',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
      END IF;
      IF p_item_name NOT IN (C_ITEM_HEADER_DESCRIPTION, C_ITEM_REFERENCE_DATE) THEN
         Update XLA_AE_LINES
         SET   CODE_COMBINATION_ID      = DECODE(p_item_name, C_ITEM_ACCOUNT,          p_value_number,   CODE_COMBINATION_ID)
              ,ACCOUNTED_DR             = DECODE(p_item_name, C_ITEM_ACCOUNTED_DR,     p_value_number,   ACCOUNTED_DR)
              ,ACCOUNTED_CR             = DECODE(p_item_name, C_ITEM_ACCOUNTED_CR,     p_value_number,   ACCOUNTED_CR)
              ,CURRENCY_CODE            = DECODE(p_item_name, C_ITEM_CURRENCY_CODE,    p_value_varchar2, CURRENCY_CODE)
              ,CURRENCY_CONVERSION_TYPE = DECODE(p_item_name, C_ITEM_CURR_CONV_TYPE,   p_value_varchar2, CURRENCY_CONVERSION_TYPE)
              ,CURRENCY_CONVERSION_RATE = DECODE(p_item_name, C_ITEM_CURR_CONV_RATE,   p_value_number,   CURRENCY_CONVERSION_RATE)
              ,CURRENCY_CONVERSION_DATE = DECODE(p_item_name, C_ITEM_CURR_CONV_DATE,   p_value_date,     CURRENCY_CONVERSION_DATE)
              ,DESCRIPTION              = DECODE(p_item_name, C_ITEM_LINE_DESCRIPTION, p_value_varchar2, DESCRIPTION)
              ,ENTERED_DR               = DECODE(p_item_name, C_ITEM_ENTERED_DR,       p_value_number,   ENTERED_DR)
              ,ENTERED_CR               = DECODE(p_item_name, C_ITEM_ENTERED_CR,       p_value_number,   ENTERED_CR)
              ,ACCOUNTING_DATE          = DECODE(p_item_name, C_ITEM_GL_DATE,          p_value_date,     ACCOUNTING_DATE)
              ,ACCOUNTING_CLASS_CODE    = DECODE(p_item_name, C_ITEM_ACCOUNTING_CLASS, p_value_varchar2, ACCOUNTING_CLASS_CODE)
         WHERE application_id = p_application_id
         AND   ae_header_id   = p_ae_header_id
         AND   ae_line_num    = DECODE(p_item_name, C_ITEM_GL_DATE, ae_line_num, p_ae_line_num);

         --------------------------------------------------------------
         -- GL Date is stored in xla_ae_lines, need to audit all lines
         --------------------------------------------------------------
         IF p_item_name = 'GL_DATE' then
            xla_datafixes_pub.audit_datafix (p_application_id   => p_application_id
                          ,p_ae_header_id     => p_ae_header_id);

         ELSE
            xla_datafixes_pub.audit_datafix (p_application_id   => p_application_id
                          ,p_ae_header_id     => p_ae_header_id
                          ,p_ae_line_num      => p_ae_line_num);
         END IF;

      END IF;

     ------------------------------------------------
     -- add control balance
     ------------------------------------------------
     IF NVL(p_item_name,'N') IN (C_ITEM_GL_DATE,      C_ITEM_ACCOUNT,
                                 C_ITEM_ACCOUNTED_DR, C_ITEM_ACCOUNTED_CR,   C_ITEM_CURRENCY_CODE,
                                 C_ITEM_ENTERED_DR,   C_ITEM_ENTERED_CR ) THEN
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Calling xla_balances_pkg.massive_update to add',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
        END IF;

	IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
	    IF (NOT xla_balances_pkg.massive_update
		 (p_application_id       => p_application_id
		 ,p_ledger_id            => NULL
		 ,p_event_id             => NULL
		 ,p_entity_id            => l_entity_id
		 ,p_request_id           => NULL
		 ,p_accounting_batch_id  => NULL
		 ,p_update_mode          => 'A'         -- Add
		 ,p_execution_mode       => 'O')) THEN  -- Online
		  xla_datafixes_pub.Log_error(p_module    => l_log_module
		    ,p_error_msg => 'Error when adding control balance calculation');
	    END IF;
	 ELSE
	    IF (NOT xla_balances_calc_pkg.massive_update
				 (p_application_id       => p_application_id
				 ,p_ledger_id            => NULL
				 ,p_event_id             => NULL
				 ,p_entity_id            => l_entity_id
				 ,p_request_id           => NULL
				 ,p_accounting_batch_id  => NULL
				 ,p_update_mode          => 'A'         -- Add
				 ,p_execution_mode       => 'O')) THEN  -- Online
		   xla_datafixes_pub.Log_error(p_module    => l_log_module
					,p_error_msg => 'Error when adding control balance calculation');
	     END IF;
	END IF;
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Returned from xla_balances_pkg.massive_update',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
        END IF;
     END IF;

     ------------------------------------------------
     -- update trial balance
     ------------------------------------------------
     IF l_gl_status in ('S','Y') THEN
        IF NVL(p_item_name,'N') IN (C_ITEM_GL_DATE,      C_ITEM_ACCOUNT,
                                    C_ITEM_ACCOUNTED_DR, C_ITEM_ACCOUNTED_CR,   C_ITEM_CURRENCY_CODE,
                                    C_ITEM_ENTERED_DR,   C_ITEM_ENTERED_CR ) THEN
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Calling xla_tb_data_manager_pvt.recreate_trial_balances',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
           END IF;
           xla_tb_data_manager_pvt.recreate_trial_balances(
                      p_application_id   => p_application_id
                     ,p_ae_header_id     => p_ae_header_id);
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Returned from xla_tb_data_manager_pvt.recreate_trial_balances',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
           END IF;
        END IF;
     END IF;

  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure update_data',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Error',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'Unexpected error',
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);
  END IF;
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace(p_msg    => 'Other error',
                      p_module => l_log_module,
                      p_level  => C_LEVEL_STATEMENT);
  END IF;
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    FND_MSG_PUB.add_exc_msg(C_DEFAULT_MODULE, l_api_name);
  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count
                           ,p_data  => x_msg_data);
END update_data;

--
-- Procedure Name: Create_Distribution_link
--
-- This procedure is called in the following cases:
-- 1. A manual journal entry is created
-- 2. A draft entry is updated (as mrc lines are recreated)
--
PROCEDURE create_distribution_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ae_line_num                IN  INTEGER
  ,p_temp_line_num              IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_ref_event_id               IN  INTEGER
  ,p_ref_temp_line_num          IN  INTEGER)
IS
   l_log_module          VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.create_distribution_link';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure create_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id   = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_line_num    = '||p_ae_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   INSERT INTO xla_distribution_links
         (application_id
         ,event_id
         ,ae_header_id
         ,ae_line_num
         ,source_distribution_type
         ,statistical_amount
         ,ref_ae_header_id
         ,ref_temp_line_num
         ,merge_duplicate_code
         ,temp_line_num
         ,ref_event_id
         ,event_class_code
         ,event_type_code
         ,unrounded_entered_dr
         ,unrounded_entered_cr
         ,unrounded_accounted_dr
         ,unrounded_accounted_cr)
  SELECT p_application_id
        ,xah.event_id
        ,p_ae_header_id
        ,p_ae_line_num                -- ae line num
        ,'XLA_MANUAL'                 -- source distribution type
        ,xal.statistical_amount       -- statistical Amount
        ,p_ref_ae_header_id           -- ref ae header id
        ,p_ref_temp_line_num          -- ref temp line num
        ,'N'                          -- merge duplicate code
        ,p_temp_line_num              -- temp line num
        ,p_ref_event_id               -- ref event id
        ,C_EVENT_CLASS_CODE_MANUAL    -- event class code
        ,C_EVENT_TYPE_CODE_MANUAL     -- event type code
        ,xal.unrounded_entered_dr
        ,xal.unrounded_entered_cr
        ,xal.unrounded_accounted_dr
        ,xal.unrounded_accounted_cr
    FROM xla_ae_headers xah
        ,xla_ae_lines   xal
   WHERE xah.application_id = p_application_id
     AND xah.ae_header_id   = p_ae_header_id
     AND xal.application_id = xah.application_id
     AND xal.ae_header_id   = xah.ae_header_id
     AND xal.ae_line_num    = p_ae_line_num;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure create_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.create_distribution_link');

END create_distribution_link;

PROCEDURE delete_distribution_link
  (p_application_id		IN  INTEGER
  ,p_ae_header_id       IN  INTEGER
  ,p_ref_ae_header_id   IN  INTEGER
  ,p_temp_line_num      IN  INTEGER)
IS
  l_log_module          VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_distribution_link';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure delete_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id   = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ref_ae_header_id   = '||p_ref_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_temp_line_num    = '||p_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   DELETE xla_distribution_links
    WHERE application_id   = p_application_id
      AND ref_ae_header_id = p_ref_ae_header_id
      AND temp_line_num    = p_temp_line_num
      AND ae_header_id     = p_ae_header_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure delete_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.delete_distribution_link');
END delete_distribution_link;

PROCEDURE update_distribution_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_temp_line_num             	IN  INTEGER
  ,p_unrounded_entered_dr       IN  NUMBER
  ,p_unrounded_entered_cr       IN  NUMBER
  ,p_unrounded_accounted_dr     IN  NUMBER
  ,p_undournde_accounted_cr     IN  NUMBER
  ,p_statistical_amount         IN  NUMBER)
IS

  l_log_module          VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.update_distribution_link';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure update_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id         = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id           = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ref_ae_header_id       = '||p_ref_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_temp_line_num          = '||p_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_unrounded_entered_dr   = '||p_unrounded_entered_dr,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_unrounded_entered_cr   = '||p_unrounded_entered_cr,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_unrounded_accounted_dr = '||p_unrounded_accounted_dr,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_undournde_accounted_cr = '||p_undournde_accounted_cr,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_statistical_amount     = '||p_statistical_amount,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   UPDATE xla_distribution_links
      SET unrounded_entered_dr   = p_unrounded_entered_dr
         ,unrounded_entered_cr   = p_unrounded_entered_cr
         ,unrounded_accounted_dr = p_unrounded_accounted_dr
         ,unrounded_accounted_cr = p_undournde_accounted_cr
         ,statistical_amount     = p_statistical_amount
    WHERE application_id         = p_application_id
      AND ref_ae_header_id       = p_ref_ae_header_id
      AND temp_line_num          = p_temp_line_num
      AND ae_header_id           = p_ae_header_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure update_distribution_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.update_distribution_link');

END update_distribution_link;

PROCEDURE create_reversal_distr_link
  (p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_ref_ae_header_id           IN  INTEGER
  ,p_ref_event_id               IN  INTEGER)
IS
   l_ref_event_id               INTEGER;
   l_log_module                 VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.create_reversal_distr_link';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure create_reversal_distr_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id   = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id     = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ref_ae_header_id = '||p_ref_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ref_event_id     = '||p_ref_event_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   IF p_ref_event_id IS NOT NULL THEN
      --
      -- Called from create_mrc_reversal_entry
      --

      l_ref_event_id := p_ref_event_id;

   ELSE
      --
      -- Called from create_reversal_entry
      --
      SELECT event_id
        INTO l_ref_event_id
        FROM xla_ae_headers
       WHERE application_id = p_application_id
         AND ae_header_id = p_ref_ae_header_id;

   END IF;

   INSERT INTO xla_distribution_links
         (application_id
         ,event_id
         ,ae_header_id
         ,ae_line_num
         ,source_distribution_type
         ,statistical_amount
         ,ref_ae_header_id
         ,ref_temp_line_num
         ,merge_duplicate_code
         ,temp_line_num
         ,ref_event_id
         ,event_class_code
         ,event_type_code
         ,unrounded_entered_dr
         ,unrounded_entered_cr
         ,unrounded_accounted_dr
         ,unrounded_accounted_cr)
   SELECT p_application_id
         ,xah.event_id
         ,p_ae_header_id
         ,ae_line_num
         ,'XLA_MANUAL'                 -- source distribution type
         ,xal.statistical_amount       -- statistical amount
         ,p_ref_ae_header_id           -- ref ae header id
         ,ae_line_num                  -- ref temp line num
         ,'N'                          -- merge duplicate code
         ,-1 * ae_line_num             -- temp line num
         ,l_ref_event_id               -- ref event id
         ,C_EVENT_CLASS_CODE_MANUAL    -- event class code
         ,C_EVENT_TYPE_CODE_MANUAL     -- event type code
         ,xal.unrounded_entered_dr
         ,xal.unrounded_entered_cr
         ,xal.unrounded_accounted_dr
         ,xal.unrounded_accounted_cr
     FROM xla_ae_headers xah
         ,xla_ae_lines   xal
    WHERE xah.application_id = p_application_id
      AND xah.ae_header_id   = p_ae_header_id
      AND xal.application_id = xah.application_id
      AND xal.ae_header_id   = xah.ae_header_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure create_reversal_distr_link',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.create_reversal_distr_link');
END create_reversal_distr_link;

FUNCTION is_reversal
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER
  ,p_temp_line_num              IN            INTEGER)
RETURN BOOLEAN IS

   l_log_module                 VARCHAR2(240);
   l_cnt                        PLS_INTEGER;
BEGIN

   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.is_reversal';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure is_reversal',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id   = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id     = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_temp_line_num    = '||p_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   SELECT COUNT(1)
     INTO l_cnt
     FROM xla_distribution_links
    WHERE application_id = p_application_id
      AND ae_header_id   = p_ae_header_id
      AND temp_line_num  = -1 * p_temp_line_num
      AND ROWNUM <=1;

   IF l_cnt = 0 THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'END of procedure is_reversal',
              p_module => l_log_module,
              p_level  => C_LEVEL_PROCEDURE);
      END IF;

     RETURN FALSE;

   ELSE

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'END of procedure is_reversal',
             p_module => l_log_module,
             p_level  => C_LEVEL_PROCEDURE);
     END IF;

     RETURN TRUE;

   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.is_reversal');
END is_reversal;

--
--  get_rev_line_info
--
--  Retrieve information of reversed lines
--
PROCEDURE get_rev_line_info
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER
  ,p_temp_line_num              IN OUT NOCOPY INTEGER
  ,p_ref_ae_header_id           OUT    NOCOPY INTEGER
  ,p_ref_event_id               OUT    NOCOPY INTEGER)
IS

   l_ref_ae_header_id           INTEGER;
   l_ref_event_id               INTEGER;
   l_temp_line_num              INTEGER;
   l_log_module                 VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.get_rev_line_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure get_rev_line_info',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id   = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id     = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_temp_line_num    = '||p_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   BEGIN

      --
      -- Retrieve information of reversal lines
      --
      SELECT ref_ae_header_id
            ,ref_event_id
            ,temp_line_num
        INTO l_ref_ae_header_id
            ,l_ref_event_id
            ,l_temp_line_num
        FROM xla_distribution_links
       WHERE application_id = p_application_id
         AND ae_header_id   = p_ae_header_id
         AND temp_line_num  = -1 * p_temp_line_num
         AND ROWNUM <= 1;

   EXCEPTION
   WHEN no_data_found THEN

      --
      -- This is not a reversal line.
      --
      l_ref_ae_header_id := p_ae_header_id;
      l_ref_event_id     := NULL;
      l_temp_line_num    := p_temp_line_num;

   END;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'l_ref_ae_header_id   = '||l_ref_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'l_ref_event_id       = '||l_ref_event_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'l_temp_line_num      = '||l_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);


   END IF;

   p_ref_ae_header_id := l_ref_ae_header_id;
   p_ref_event_id     := l_ref_event_id;
   p_temp_line_num    := l_temp_line_num;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure get_rev_line_info',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.get_rev_line_info');
END get_rev_line_info;

--
--  get_mrc_rev_line_info
--
--  Retrieve information of reversed mrc lines
--
PROCEDURE get_mrc_rev_line_info
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER -- ae_header_id for primary ledgers
  ,p_temp_line_num              IN OUT NOCOPY INTEGER
  ,p_ref_ae_header_id           OUT    NOCOPY INTEGER
  ,p_ref_temp_line_num          OUT    NOCOPY INTEGER
  ,p_ref_event_id               OUT    NOCOPY INTEGER)
IS

   l_ref_ae_header_id           INTEGER;
   l_ref_event_id               INTEGER;
   l_temp_line_num              INTEGER;
   l_ref_temp_line_num          INTEGER;
   l_log_module                 VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.get_mrc_rev_line_info';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure get_mrc_rev_line_info',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'p_application_id   = '||p_application_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_ae_header_id     = '||p_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'p_temp_line_num    = '||p_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;


   --
   --  Find lines with the same event as those of non-mrc JEs
   --  but with different header ids => original mrc lines reversed
   --

   SELECT ae_header_id
         ,event_id
         ,-1 * temp_line_num
         ,temp_line_num
     INTO l_ref_ae_header_id
         ,l_ref_event_id
         ,l_temp_line_num
         ,l_ref_temp_line_num
     FROM xla_distribution_links
    WHERE event_id =
            (SELECT ref_event_id
               FROM xla_distribution_links
              WHERE application_id = p_application_id      -- non mrc
                AND ae_header_id   = p_ae_header_id        -- non mrc
                AND temp_line_num  = -1 * p_temp_line_num  -- non mrc
                AND ROWNUM <= 1)
      AND ae_header_id <>
            (SELECT ref_ae_header_id
               FROM xla_distribution_links
              WHERE application_id = p_application_id      -- non mrc
                AND ae_header_id   = p_ae_header_id        -- non mrc
                AND temp_line_num  = -1 * p_temp_line_num  -- non mrc
                AND ROWNUM <= 1)
      AND temp_line_num = p_temp_line_num;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace(p_msg    => 'l_ref_ae_header_id   = '||l_ref_ae_header_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'l_ref_event_id       = '||l_ref_event_id,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

      trace(p_msg    => 'l_temp_line_num      = '||l_temp_line_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_STATEMENT);

   END IF;

   p_ref_ae_header_id  := l_ref_ae_header_id;
   p_ref_event_id      := l_ref_event_id;
   p_temp_line_num     := l_temp_line_num;
   p_ref_temp_line_num := l_ref_temp_line_num;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure get_mrc_rev_line_info',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
     (p_location => 'xla_journal_entries_pkg.get_mrc_rev_line_info');
END get_mrc_rev_line_info;

PROCEDURE IsReversible
  (p_application_id             IN            INTEGER
  ,p_ae_header_id               IN            INTEGER -- ae_header_id for primary ledgers
  ,p_reversible_flag            OUT    NOCOPY VARCHAR2
  )
IS

cursor c_reversible is
select 'Y'
from xla_distribution_links
where ae_header_id = ref_ae_header_id
and ref_temp_line_num is null
and ae_header_id= p_ae_header_id
and application_id=p_application_id
and not exists (
                select 1
                from xla_distribution_links
                where ae_header_id<>ref_ae_header_id
                and ref_ae_header_id=p_ae_header_id
                and application_id=p_application_id
                );
BEGIN
p_reversible_flag := 'N';
open c_reversible;
fetch c_reversible into p_reversible_flag;
close c_reversible;

Exception
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_journal_entries_pkg.isReversible');
END IsReversible;
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

   g_log_level      := C_LEVEL_STATEMENT;
   g_log_enabled    := TRUE;

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_journal_entries_pkg;

/
