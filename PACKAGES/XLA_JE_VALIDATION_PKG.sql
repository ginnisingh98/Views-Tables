--------------------------------------------------------
--  DDL for Package XLA_JE_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_JE_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajebal.pkh 120.19 2006/05/23 23:56:53 wychan ship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

TYPE t_array_int     IS TABLE OF INTEGER      INDEX BY BINARY_INTEGER;
TYPE t_array_varchar IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: balance_amounts
-- Description: This function handle the validation and the balancing
--              requirement for a standard journal entry.
-- Result code:
--      0 - Completed successfully and no error is found
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_amounts
  (p_application_id		IN INTEGER
  ,p_mode                       IN VARCHAR2               -- 4262811
  ,p_end_date                   IN DATE    DEFAULT NULL   -- 4262811
  ,p_ledger_id			IN INTEGER DEFAULT NULL
  ,p_budgetary_control_mode     IN VARCHAR2
  ,p_accounting_mode            IN VARCHAR2)
RETURN INTEGER;

--=============================================================================
--
-- Name: balance_manual_entry
-- Description: This function handle the validation and the balancing
--              requirement for a manual journal entry.
-- Result code:
--      0 - Completed successfully and no error is found
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_manual_entry
  (p_application_id     IN INTEGER
  ,p_balance_flag       IN BOOLEAN DEFAULT TRUE
  ,p_accounting_mode    IN VARCHAR2
  ,p_ledger_ids         IN t_array_int
  ,p_ae_header_ids      IN t_array_int
  ,p_end_date           IN DATE     -- 4262811
  ,p_status_codes       IN OUT NOCOPY t_array_varchar)
RETURN INTEGER;

--=============================================================================
--
-- Name: balance_tpm_entry
-- Description: This function handle the validation and the balancing
--              requirement for third party merge journal entry.
-- Result code:
--      0 - Completed successfully and no error is found
--      1 - Error is found in the balancing program
--
--=============================================================================
FUNCTION balance_tpm_amounts
  (p_application_id             IN  INTEGER
  ,p_ledger_id                  IN  INTEGER
  ,p_ledger_array               IN  xla_accounting_cache_pkg.t_array_ledger_id
  ,p_accounting_mode            IN VARCHAR2
) RETURN INTEGER;


--=============================================================================
--
-- Name: validate_period
-- Description: Determine the period name of the gl date, and determine if
--		the period is an open period.
-- Result code:
--      0 - the gl date is valid
--      1 - the gl date does not belong to an open accounting period
--	2 - the gl date does not belong to any accounting period of the ledger
--
--=============================================================================
FUNCTION validate_period
  (p_ledger_id                  IN INTEGER
  ,p_accounting_date        	IN DATE
  ,p_period_name           	OUT NOCOPY VARCHAR2)
RETURN INTEGER;

--=============================================================================
--
-- Name: get_period_name
-- Description: Return the period name of the gl date, and the closing status
--		of the period.
--
--=============================================================================
FUNCTION get_period_name
  (p_ledger_id          IN INTEGER
  ,p_accounting_date    IN DATE
  ,p_closing_status     OUT NOCOPY VARCHAR2
  ,p_period_type	OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

END xla_je_validation_pkg;
 

/
