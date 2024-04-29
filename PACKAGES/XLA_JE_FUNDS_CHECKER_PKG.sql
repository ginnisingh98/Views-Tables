--------------------------------------------------------
--  DDL for Package XLA_JE_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_JE_FUNDS_CHECKER_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajefck.pkh 120.4 2005/08/17 20:46:57 dcshah ship $ */
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

FUNCTION reserve_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id                 IN INTEGER
   ,p_packet_id                 OUT NOCOPY INTEGER)
RETURN VARCHAR2;

FUNCTION unreserve_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id                 IN INTEGER
   ,p_packet_id			IN INTEGER)
RETURN VARCHAR2;

PROCEDURE check_funds
   (p_ae_header_id              IN INTEGER
   ,p_application_id		IN INTEGER
   ,p_ledger_id                 IN INTEGER
   ,p_packet_id			IN INTEGER
   ,p_retcode			OUT NOCOPY VARCHAR2);

PROCEDURE insert_check_funds_row
   (p_packet_id                 IN INTEGER
   ,p_ledger_id                 IN INTEGER
   ,p_application_id            IN INTEGER
   ,p_ae_header_id              IN INTEGER
   ,p_ae_line_num               IN INTEGER
   ,p_gl_date                   IN DATE
   ,p_balance_type_code         IN VARCHAR2
   ,p_je_category_name          IN VARCHAR2
   ,p_budget_version_id         IN INTEGER
   ,p_encumbrance_type_id       IN INTEGER
   ,p_code_combination_id       IN INTEGER
   ,p_currency_code             IN VARCHAR2
   ,p_entered_dr                IN NUMBER
   ,p_entered_cr                IN NUMBER
   ,p_accounted_dr              IN NUMBER
   ,p_accounted_cr              IN NUMBER
   ,p_ussgl_transaction_code    IN VARCHAR2
   ,p_event_id                  IN NUMBER);


END xla_je_funds_checker_pkg;
 

/
