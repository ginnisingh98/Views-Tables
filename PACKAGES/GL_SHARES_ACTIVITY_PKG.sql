--------------------------------------------------------
--  DDL for Package GL_SHARES_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SHARES_ACTIVITY_PKG" AUTHID CURRENT_USER AS
/* $Header: glistacs.pls 120.3 2005/05/05 01:21:52 kvora ship $ */

-- Package
--   GL_SHARES_ACTIVITY_PKG
-- Purpose
--   To create GL_SHARES_ACTIVITY_PKG package.
-- History
--   08/25/98    K Vora           Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure the combination of set_of_books_id and
  --   activity_date is unique within the GL_SHARES_ACTIVITY table.
  -- History
  --   08/25/98   K Vora         Created
  -- Arguments
  --   X_rowid               The ID of the row to be checked
  --   X_ledger_id           The ledger_id to be checked
  --   X_activity_date       The activity date to be checked
  -- Example
  --   GL_SHARES_ACTIVITY_PKG.check_unique('123:A:456', 46,25-AUG-1990);
  -- Notes
  --
  PROCEDURE check_unique( X_rowid              VARCHAR2,
                          X_ledger_id          NUMBER,
                          X_activity_date      DATE,
                          X_activity_type_code VARCHAR2);

END GL_SHARES_ACTIVITY_PKG;

 

/
