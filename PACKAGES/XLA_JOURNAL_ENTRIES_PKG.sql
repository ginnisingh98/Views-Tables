--------------------------------------------------------
--  DDL for Package XLA_JOURNAL_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_JOURNAL_ENTRIES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajejey.pkh 120.14.12010000.3 2008/11/13 13:30:21 karamakr ship $ */
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

XLA_BALANCE_CALCULATION_ERROR	EXCEPTION;

C_COMPLETION_SUCCESS	CONSTANT VARCHAR2(1) := 'S';
C_COMPLETION_FAILED	CONSTANT VARCHAR2(1) := 'X';

C_DELETE_NORMAL_MODE    CONSTANT VARCHAR2(1) := 'N';

/* Bug 7011889 - Added 2 global variables to handle Encumbarance reversal */
g_rev_event_id          INTEGER              := NULL;
g_entity_id             INTEGER              := NULL;
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

-- This API is called by the MJE page, and the ledger determines if the JE
-- is created with budgetary control event.
PROCEDURE create_journal_entry_header
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER      DEFAULT NULL
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER      DEFAULT NULL
  ,p_reference_date             IN  DATE         DEFAULT NULL
  ,p_attribute_category		IN  VARCHAR2	 DEFAULT NULL
  ,p_attribute1                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute2                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute3                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute4                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute5                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute6                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute7                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute8                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute9                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute10                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute11                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute12                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute13                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute14                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute15                IN  VARCHAR2     DEFAULT NULL
  ,p_ae_header_id               OUT NOCOPY INTEGER
  ,p_event_id			OUT NOCOPY INTEGER
  ,p_period_name		OUT NOCOPY VARCHAR2
  ,p_creation_date		OUT NOCOPY DATE
  ,p_created_by			OUT NOCOPY INTEGER
  ,p_last_update_date		OUT NOCOPY DATE
  ,p_last_updated_by		OUT NOCOPY INTEGER
  ,p_last_update_login		OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode			IN VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

-- The following API contains p_budgetary_control_flag.  The caller determine if the
-- journal entry should be created with bc event.
PROCEDURE create_journal_entry_header
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_balance_type_code          IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER
  ,p_reference_date             IN  DATE
  ,p_attribute_category         IN  VARCHAR2
  ,p_attribute1                 IN  VARCHAR2
  ,p_attribute2                 IN  VARCHAR2
  ,p_attribute3                 IN  VARCHAR2
  ,p_attribute4                 IN  VARCHAR2
  ,p_attribute5                 IN  VARCHAR2
  ,p_attribute6                 IN  VARCHAR2
  ,p_attribute7                 IN  VARCHAR2
  ,p_attribute8                 IN  VARCHAR2
  ,p_attribute9                 IN  VARCHAR2
  ,p_attribute10                IN  VARCHAR2
  ,p_attribute11                IN  VARCHAR2
  ,p_attribute12                IN  VARCHAR2
  ,p_attribute13                IN  VARCHAR2
  ,p_attribute14                IN  VARCHAR2
  ,p_attribute15                IN  VARCHAR2
  ,p_budgetary_control_flag     IN  VARCHAR2
  ,p_ae_header_id               OUT NOCOPY INTEGER
  ,p_event_id                   OUT NOCOPY INTEGER
  ,p_period_name                OUT NOCOPY VARCHAR2
  ,p_creation_date              OUT NOCOPY DATE
  ,p_created_by                 OUT NOCOPY INTEGER
  ,p_last_update_date           OUT NOCOPY DATE
  ,p_last_updated_by            OUT NOCOPY INTEGER
  ,p_last_update_login          OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode                   IN VARCHAR2     DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE update_journal_entry_header
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_legal_entity_id            IN  INTEGER      DEFAULT NULL
  ,p_gl_date                    IN  DATE
  ,p_accounting_entry_type_code IN  VARCHAR2
  ,p_description                IN  VARCHAR2
  ,p_je_category_name           IN  VARCHAR2
  ,p_budget_version_id          IN  INTEGER      DEFAULT NULL
  ,p_reference_date             IN  DATE         DEFAULT NULL
  ,p_attribute_category		IN  VARCHAR2	DEFAULT NULL
  ,p_attribute1                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute2                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute3                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute4                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute5                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute6                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute7                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute8                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute9                 IN  VARCHAR2     DEFAULT NULL
  ,p_attribute10                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute11                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute12                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute13                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute14                IN  VARCHAR2     DEFAULT NULL
  ,p_attribute15                IN  VARCHAR2     DEFAULT NULL
  ,p_period_name		OUT NOCOPY VARCHAR2
  ,p_last_update_date		OUT NOCOPY DATE
  ,p_last_updated_by		OUT NOCOPY INTEGER
  ,p_last_update_login		OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode			IN VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE delete_journal_entry
  (p_ae_header_id               IN INTEGER
  ,p_application_id             IN INTEGER
  ,p_mode                       IN VARCHAR2     DEFAULT C_DELETE_NORMAL_MODE
  ,p_msg_mode                   IN VARCHAR2     DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE delete_journal_entries
  (p_event_id                   IN INTEGER
  ,p_application_id             IN INTEGER);

PROCEDURE create_journal_entry_line
  (p_ae_header_id               IN INTEGER
  ,p_displayed_line_number	IN INTEGER
  ,p_application_id             IN INTEGER
  ,p_code_combination_id        IN INTEGER
  ,p_gl_transfer_mode           IN VARCHAR2
  ,p_accounting_class_code      IN VARCHAR2
  ,p_entered_dr                 IN OUT NOCOPY NUMBER
  ,p_entered_cr                 IN OUT NOCOPY NUMBER
  ,p_currency_code              IN OUT NOCOPY VARCHAR2
  ,p_accounted_dr               IN OUT NOCOPY NUMBER
  ,p_accounted_cr               IN OUT NOCOPY NUMBER
  ,p_conversion_type            IN OUT NOCOPY VARCHAR2
  ,p_conversion_date            IN OUT NOCOPY DATE
  ,p_conversion_rate            IN OUT NOCOPY NUMBER
  ,p_party_type_code            IN VARCHAR2     DEFAULT NULL
  ,p_party_id                   IN INTEGER      DEFAULT NULL
  ,p_party_site_id              IN INTEGER      DEFAULT NULL
  ,p_description                IN VARCHAR2     DEFAULT NULL
  ,p_statistical_amount         IN NUMBER       DEFAULT NULL
  ,p_jgzz_recon_ref             IN VARCHAR2     DEFAULT NULL
  ,p_attribute_category		    IN VARCHAR2 	DEFAULT NULL
  ,p_encumbrance_type_id        IN  INTEGER     DEFAULT NULL
  ,p_attribute1                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute2                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute3                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute4                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute5                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute6                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute7                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute8                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute9                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute10                IN VARCHAR2     DEFAULT NULL
  ,p_attribute11                IN VARCHAR2     DEFAULT NULL
  ,p_attribute12                IN VARCHAR2     DEFAULT NULL
  ,p_attribute13                IN VARCHAR2     DEFAULT NULL
  ,p_attribute14                IN VARCHAR2     DEFAULT NULL
  ,p_attribute15                IN VARCHAR2     DEFAULT NULL
  ,p_ae_line_num                OUT NOCOPY INTEGER
  ,p_creation_date		OUT NOCOPY DATE
  ,p_created_by			OUT NOCOPY INTEGER
  ,p_last_update_date		OUT NOCOPY DATE
  ,p_last_updated_by		OUT NOCOPY INTEGER
  ,p_last_update_login		OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode			IN VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);

PROCEDURE update_journal_entry_line
  (p_ae_header_id               IN INTEGER
  ,p_ae_line_num                IN INTEGER
  ,p_displayed_line_number	IN INTEGER
  ,p_application_id             IN INTEGER
  ,p_code_combination_id        IN INTEGER
  ,p_gl_transfer_mode           IN VARCHAR2
  ,p_accounting_class_code      IN VARCHAR2
  ,p_entered_dr                 IN OUT NOCOPY NUMBER
  ,p_entered_cr                 IN OUT NOCOPY NUMBER
  ,p_currency_code              IN OUT NOCOPY VARCHAR2
  ,p_accounted_dr               IN OUT NOCOPY NUMBER
  ,p_accounted_cr               IN OUT NOCOPY NUMBER
  ,p_conversion_type            IN OUT NOCOPY VARCHAR2
  ,p_conversion_date            IN OUT NOCOPY DATE
  ,p_conversion_rate            IN OUT NOCOPY NUMBER
  ,p_party_type_code            IN VARCHAR2     DEFAULT NULL
  ,p_party_id                   IN INTEGER      DEFAULT NULL
  ,p_party_site_id              IN INTEGER      DEFAULT NULL
  ,p_description                IN VARCHAR2     DEFAULT NULL
  ,p_statistical_amount         IN NUMBER       DEFAULT NULL
  ,p_jgzz_recon_ref             IN VARCHAR2     DEFAULT NULL
  ,p_attribute_category		    IN VARCHAR2   	DEFAULT NULL
  ,p_encumbrance_type_id        IN  INTEGER     DEFAULT NULL
  ,p_attribute1                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute2                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute3                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute4                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute5                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute6                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute7                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute8                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute9                 IN VARCHAR2     DEFAULT NULL
  ,p_attribute10                IN VARCHAR2     DEFAULT NULL
  ,p_attribute11                IN VARCHAR2     DEFAULT NULL
  ,p_attribute12                IN VARCHAR2     DEFAULT NULL
  ,p_attribute13                IN VARCHAR2     DEFAULT NULL
  ,p_attribute14                IN VARCHAR2     DEFAULT NULL
  ,p_attribute15                IN VARCHAR2     DEFAULT NULL
  ,p_last_update_date		OUT NOCOPY DATE
  ,p_last_updated_by		OUT NOCOPY INTEGER
  ,p_last_update_login		OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY INTEGER
  ,p_msg_mode			IN VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);


PROCEDURE delete_journal_entry_line
  (p_ae_header_id               IN  INTEGER
  ,p_ae_line_num                IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_msg_mode			IN  VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);


PROCEDURE complete_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr		IN  VARCHAR2
  ,p_je_source_name		IN  VARCHAR2
  ,p_ae_status_code             OUT NOCOPY VARCHAR2
  ,p_funds_status_code          OUT NOCOPY VARCHAR2
  ,p_completion_seq_value       OUT NOCOPY VARCHAR2
  ,p_completion_seq_ver_id      OUT NOCOPY INTEGER
  ,p_completed_date             OUT NOCOPY DATE
  ,p_gl_transfer_status_code    OUT NOCOPY VARCHAR2
  ,p_last_update_date		OUT NOCOPY DATE
  ,p_last_updated_by		OUT NOCOPY INTEGER
  ,p_last_update_login		OUT NOCOPY INTEGER
  ,p_transfer_request_id	OUT NOCOPY INTEGER
  ,p_retcode                    OUT NOCOPY VARCHAR2
  ,p_msg_mode			IN  VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE);


/* Bug 7011889 - Overloading for Encumbarance DFIX API  */

PROCEDURE reverse_journal_entry
  (p_array_je_header_id         IN  xla_je_validation_pkg.t_array_int
  ,p_application_id             IN  INTEGER
  ,p_reversal_method            IN  VARCHAR2
  ,p_gl_date                    IN  DATE
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr		IN  VARCHAR2
  ,p_je_source_name		IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_header_id              OUT NOCOPY INTEGER
  ,p_rev_event_id               OUT NOCOPY INTEGER
  ,p_completion_retcode        	OUT NOCOPY VARCHAR2
  ,p_transfer_request_id	OUT NOCOPY INTEGER);


PROCEDURE reverse_journal_entry
  (p_ae_header_id               IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_reversal_method            IN  VARCHAR2
  ,p_gl_date                    IN  DATE
  ,p_completion_option          IN  VARCHAR2
  ,p_functional_curr		IN  VARCHAR2
  ,p_je_source_name		IN  VARCHAR2
  ,p_msg_mode			IN  VARCHAR2 	DEFAULT xla_exceptions_pkg.C_STANDARD_MESSAGE
  ,p_rev_header_id              OUT NOCOPY INTEGER
  ,p_rev_event_id               OUT NOCOPY INTEGER
  ,p_completion_retcode        	OUT NOCOPY VARCHAR2
  ,p_transfer_request_id	OUT NOCOPY INTEGER);

PROCEDURE funds_check_result
  (p_packet_id                  IN  INTEGER
  ,p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_sequence_id                IN OUT NOCOPY INTEGER);

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
  ,x_msg_data                   OUT NOCOPY VARCHAR2);

PROCEDURE IsReversible
  (p_application_id       IN            INTEGER
  ,p_ae_header_id         IN            INTEGER
  ,p_reversible_flag      OUT    NOCOPY VARCHAR2
  ) ;

END xla_journal_entries_pkg;

/
