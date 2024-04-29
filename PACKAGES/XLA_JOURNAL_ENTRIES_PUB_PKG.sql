--------------------------------------------------------
--  DDL for Package XLA_JOURNAL_ENTRIES_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_JOURNAL_ENTRIES_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajejep.pkh 120.7 2006/05/30 16:49:38 wychan ship $ */
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

C_COMPLETION_OPTION_SAVE        CONSTANT VARCHAR2(1)    := 'S';
C_COMPLETION_OPTION_DRAFT       CONSTANT VARCHAR2(1)    := 'D';
C_COMPLETION_OPTION_FINAL       CONSTANT VARCHAR2(1)    := 'F';
C_COMPLETION_OPTION_TRANSFER    CONSTANT VARCHAR2(1)    := 'T';
C_COMPLETION_OPTION_POST        CONSTANT VARCHAR2(1)    := 'P';

C_REVERSAL_CHANGE_SIGN          CONSTANT VARCHAR2(30)    := 'SIGN';
C_REVERSAL_SWITCH_DR_CR         CONSTANT VARCHAR2(30)    := 'SIDE';

C_STATUS_INCOMPLETE             CONSTANT VARCHAR2(1) := 'N';
C_STATUS_INVALID                CONSTANT VARCHAR2(1) := 'I';
C_STATUS_DRAFT                  CONSTANT VARCHAR2(1) := 'D';
C_STATUS_FINAL                  CONSTANT VARCHAR2(1) := 'F';

C_DELETE_NORMAL_MODE            CONSTANT VARCHAR2(1)    := 'N';
C_DELETE_FORCE_MODE             CONSTANT VARCHAR2(1)    := 'F';

XLA_BALANCE_CALCULATION_ERROR	EXCEPTION;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

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
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_ae_header_id               OUT NOCOPY INTEGER
  ,x_event_id                   OUT NOCOPY INTEGER
);

PROCEDURE create_journal_entry_line
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_displayed_line_number      IN  INTEGER
  ,p_code_combination_id        IN  INTEGER
  ,p_gl_transfer_mode           IN  VARCHAR2
  ,p_accounting_class_code      IN  VARCHAR2
  ,p_currency_code              IN  VARCHAR2
  ,p_entered_dr                 IN  NUMBER
  ,p_entered_cr                 IN  NUMBER
  ,p_accounted_dr               IN  NUMBER
  ,p_accounted_cr               IN  NUMBER
  ,p_conversion_type            IN  VARCHAR2
  ,p_conversion_date            IN  DATE
  ,p_conversion_rate            IN  NUMBER
  ,p_party_type_code            IN  VARCHAR2
  ,p_party_id                   IN  INTEGER
  ,p_party_site_id              IN  INTEGER
  ,p_description                IN  VARCHAR2
  ,p_statistical_amount         IN  NUMBER
  ,p_jgzz_recon_ref             IN  VARCHAR2
  ,p_attribute_category         IN  VARCHAR2
  ,p_encumbrance_type_id        IN  INTEGER
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
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_ae_line_num                OUT NOCOPY INTEGER
);


PROCEDURE complete_journal_entry
  (p_api_version                IN  NUMBER
  ,p_init_msg_list              IN  VARCHAR2
  ,p_application_id             IN  INTEGER
  ,p_ae_header_id               IN  INTEGER
  ,p_completion_option          IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
  ,x_completion_retcode         OUT NOCOPY VARCHAR2);


END xla_journal_entries_pub_pkg;
 

/
