--------------------------------------------------------
--  DDL for Package GL_SYSTEM_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SYSTEM_USAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: glistsus.pls 120.4 2005/05/05 01:24:26 kvora ship $ */
  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values of some columns from gl_system_usages
  -- History
  --   11-DEC-95  E. Rumanang  Created.
  -- Arguments
  --   x_average_balances_flag
  --   x_consolidation_ledger_flag
  --
  PROCEDURE select_columns(
              x_average_balances_flag		IN OUT NOCOPY  VARCHAR2,
              x_consolidation_ledger_flag       IN OUT NOCOPY  VARCHAR2);

END gl_system_usages_pkg;

 

/
