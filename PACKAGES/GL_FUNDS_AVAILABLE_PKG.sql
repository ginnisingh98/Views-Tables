--------------------------------------------------------
--  DDL for Package GL_FUNDS_AVAILABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FUNDS_AVAILABLE_PKG" AUTHID CURRENT_USER AS
/* $Header: glifunds.pls 120.5 2006/05/24 11:49:51 kthatava ship $ */
--
-- Package
--   gl_funds_available_pkg
-- Purpose
--   To group all the routines for gl_funds_available_pkg.
--   This package is mainly used for funds available inquiry form.


  --
  -- Procedure
  --   is_po_installed
  -- Purpose
  --   To find out whether po is installed or not.
  -- History
  --   30-AUG-94  E. Rumanang  Created.
  -- Arguments
  --   N.A.
FUNCTION is_po_installed RETURN BOOLEAN;

  --
  -- Procedure
  --   current_budget_info
  -- Purpose
  --   Returns budget info about the current budget and whether po is
  --   installed, and ids and names of PO encumbrance types
  -- History
  --   07-MAR-95    K. Nigam    Created.
  -- Arguments
  --         x_ledger_id                 NUMBER,   ledger_id
  --         x_budget_version_id  IN OUT NOCOPY NUMBER,
  --         x_budget_name        IN OUT NOCOPY VARCHAR2,
  --         x_bj_required_flag   IN OUT NOCOPY VARCHAR2 budget journals required flag
  --         x_budget_type        IN OUT NOCOPY VARCHAR2,
  --         x_budget_status      IN OUT NOCOPY VARCHAR2,
  --         x_latest_opened_year IN OUT NOCOPY NUMBER,
  --         x_first_valid_period IN OUT NOCOPY VARCHAR2,
  --         x_last_valid_period  IN OUT NOCOPY VARCHAR2,
  --         x_is_po_installed    IN OUT NOCOPY BOOLEAN,   is PO fully installed
  --         x_req_id             IN OUT NOCOPY NUMBER,
  --	     x_po_id              IN OUT NOCOPY NUMBER,
  --	     x_req_name           IN OUT NOCOPY VARCHAR2,
  --         x_po_name            IN OUT NOCOPY VARCHAR2,
  --	     x_oth_name           IN OUT NOCOPY VARCHAR2);

PROCEDURE current_budget_info (
            x_ledger_id                 NUMBER,
            x_budget_version_id  IN OUT NOCOPY NUMBER,
            x_budget_name        IN OUT NOCOPY VARCHAR2,
            x_bj_required_flag   IN OUT NOCOPY VARCHAR2,
            x_budget_type        IN OUT NOCOPY VARCHAR2,
            x_budget_status      IN OUT NOCOPY VARCHAR2,
            x_latest_opened_year IN OUT NOCOPY NUMBER,
            x_first_valid_period IN OUT NOCOPY VARCHAR2,
            x_last_valid_period  IN OUT NOCOPY VARCHAR2,
            x_is_po_installed    IN OUT NOCOPY BOOLEAN,
            x_req_id             IN OUT NOCOPY NUMBER,
	    x_po_id              IN OUT NOCOPY NUMBER,
	    x_req_name           IN OUT NOCOPY VARCHAR2,
            x_po_name            IN OUT NOCOPY VARCHAR2,
	    x_oth_name           IN OUT NOCOPY VARCHAR2);




  --
  -- Procedure
  --   calc_funds
  -- Purpose
  --   To calculate the funds available amount for
  --   all balance types
  -- History
  --   07-MAR-95 K. Nigam      Created.
  -- Arguments
  --    x_amount_type                   Amount_type
  --    x_code_combination_id           Code combination id of the account
  --    x_account_type                  Account type
  --    x_template_id                   Template ID
  --    x_ledger_id                     ID of the ledger
  --    x_currency_code                 Functional currency code
  --    x_po_install_flag               Flag whether PO is installed or not
  --    x_accounted_period_type         Period type
  --    x_period_set_name               Period set name
  --    x_period_name                   Period name
  --    x_period_num                    Period number
  --    x_quarter_num                   Quarter number
  --    x_period_year                   Period year
  --    x_closing_status                Closing status
  --    x_budget_version_id             Budget ID
  --    x_encumbrance_type_id           Encumbrance yype ID
  --    x_req_encumbrance_id            Requisition encumbrance ID
  --    x_po_encumbrance_id             Purchasing encumbrance ID
  --    x_budget                        Budget amount
  --    x_encumbrance                   Encumbrance amount
  --    x_actual                        Actual amount
  --    x_funds_available               Funds available amount
  --    x_req_encumbrance_amount        Requisition amount
  --    x_po_encumbrance_amount         Purchasing amount
  --    x_other_encumbrance_amount      Other amount

PROCEDURE calc_funds(
            x_amount_type                   VARCHAR2,
            x_code_combination_id           NUMBER,
            x_account_type                  VARCHAR2,
            x_template_id                   NUMBER,
            x_ledger_id                     NUMBER,
            x_currency_code                 VARCHAR2,
            x_po_install_flag               VARCHAR2,
            x_accounted_period_type         VARCHAR2,
            x_period_set_name               VARCHAR2,
            x_period_name                   VARCHAR2,
            x_period_num                    NUMBER,
            x_quarter_num                   NUMBER,
            x_period_year                   NUMBER,
            x_closing_status                VARCHAR2,
            x_budget_version_id             NUMBER,
            x_encumbrance_type_id           NUMBER,
            x_req_encumbrance_id            NUMBER,
            x_po_encumbrance_id             NUMBER,
            x_budget                        IN OUT NOCOPY NUMBER,
            x_encumbrance                   IN OUT NOCOPY NUMBER,
            x_actual                        IN OUT NOCOPY NUMBER,
            x_funds_available               IN OUT NOCOPY NUMBER,
            x_req_encumbrance_amount        IN OUT NOCOPY NUMBER,
            x_po_encumbrance_amount         IN OUT NOCOPY NUMBER,
            x_other_encumbrance_amount      IN OUT NOCOPY NUMBER );


  --
  -- Procedure
  --   calc_funds_period
  -- Purpose
  --   To calculate the funds available for each period
  -- History
  --   23-May-06  Krishna      Created.
  -- Arguments
  --    x_code_combination_id           Code combination id of the account
  --    x_account_type                  Account type
  --    x_template_id                   Template ID
  --    x_ledger_id                     ID of the ledger
  --    x_currency_code                 Functional currency code
  --    x_po_install_flag               Flag whether PO is installed or not
  --    x_accounted_period_type         Period type
  --    x_period_set_name               Period set name
  --    x_period_name                   Period name
  --    x_period_num                    Period number
  --    x_quarter_num                   Quarter number
  --    x_period_year                   Period year
  --    x_closing_status                Closing status
  --    x_budget_version_id             Budget ID
  --    x_encumbrance_type_id           Encumbrance yype ID
  --    x_req_encumbrance_id            Requisition encumbrance ID
  --    x_po_encumbrance_id             Purchasing encumbrance ID
  --    x_budget                        Budget amount
  --    x_encumbrance                   Encumbrance amount
  --    x_actual                        Actual amount
  --    x_funds_available               Funds available amount
  --    x_req_encumbrance_amount        Requisition amount
  --    x_po_encumbrance_amount         Purchasing amount
  --    x_other_encumbrance_amount      Other amount


PROCEDURE calc_funds_period(
            x_code_combination_id           NUMBER,
            x_account_type                  VARCHAR2,
            x_template_id                   NUMBER,
            x_ledger_id                     NUMBER,
            x_currency_code                 VARCHAR2,
            x_po_install_flag               VARCHAR2,
            x_accounted_period_type         VARCHAR2,
            x_period_set_name               VARCHAR2,
            x_period_name                   VARCHAR2,
            x_period_num                    NUMBER,
            x_quarter_num                   NUMBER,
            x_period_year                   NUMBER,
            x_closing_status                VARCHAR2,
            x_budget_version_id             NUMBER,
            x_encumbrance_type_id           NUMBER,
            x_req_encumbrance_id            NUMBER,
            x_po_encumbrance_id             NUMBER,
            x_budget                        IN OUT NOCOPY NUMBER,
            x_encumbrance                   IN OUT NOCOPY NUMBER,
            x_actual                        IN OUT NOCOPY NUMBER,
            x_funds_available               IN OUT NOCOPY NUMBER,
            x_req_encumbrance_amount        IN OUT NOCOPY NUMBER,
            x_po_encumbrance_amount         IN OUT NOCOPY NUMBER,
            x_other_encumbrance_amount      IN OUT NOCOPY NUMBER );


  --
  -- Procedure
  --   calc_funds
  -- Purpose
  --   To serve as wrapper for the above cal_cunds procedure
  --
  -- History
  --   22-Jan-2006 N.Venkatesh      Created.
  -- Arguments
  --    p_ccid                          Code combination id of the account
  --    p_template_id                   Template ID
  --    p_ledger_id                     Ledger ID
  --    p_period_name                   Period Name
  --    p_currency_code                 Currency code

FUNCTION calc_funds(
            p_ccid                          IN VARCHAR2,
            p_template_id                   IN NUMBER,
            p_ledger_id                     IN NUMBER,
            p_period_name                   IN VARCHAR2,
            p_currency_code                 IN VARCHAR2) RETURN NUMBER;
END gl_funds_available_pkg;

 

/
