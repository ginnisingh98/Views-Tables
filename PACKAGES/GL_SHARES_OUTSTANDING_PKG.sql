--------------------------------------------------------
--  DDL for Package GL_SHARES_OUTSTANDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SHARES_OUTSTANDING_PKG" AUTHID CURRENT_USER AS
/* $Header: glistous.pls 120.3 2005/05/05 01:23:44 kvora ship $ */

-- Package
--   GL_SHARES_OUTSTANDING_PKG
-- Purpose
--   To create GL_SHARES_OUTSTANDING_PKG package.
-- History
--   08/25/98    K Vora           Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure the combination of set_of_books_id,
  --   fiscal_year, share_measure_code and measure_type_code is
  --   unique within the GL_SHARES_OUTSTANDING table.
  -- History
  --   08/25/98   K Vora         Created
  -- Arguments
  --   X_rowid               The ID of the row to be checked
  --   X_ledger_id           The ledger_id to be checked
  --   X_fiscal_year         The fiscal_year to be checked
  --   X_share_measure_code  The share measure code to be checked
  --   X_measure_type_code   The measure type code to be checked
  -- Example
  --   GL_SHARES_OUTSTANDING_PKG.check_unique('123:A:456', 46,
  --                                           1990, 'BASIC', 'ACTUAL' );
  -- Notes
  --
  PROCEDURE check_unique( X_rowid              VARCHAR2,
                          X_ledger_id    NUMBER,
                          X_fiscal_year        NUMBER,
                          X_share_measure_code VARCHAR2,
                          X_measure_type_code  VARCHAR2);

END GL_SHARES_OUTSTANDING_PKG;

 

/
