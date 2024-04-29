--------------------------------------------------------
--  DDL for Package BUDGET_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BUDGET_INQUIRY_PKG" AUTHID CURRENT_USER AS
/* $Header: gliiqbds.pls 120.2 2003/04/24 01:29:12 djogg ship $ */
--
-- Package
--   budget_inquiry_pkg
-- Purpose
--   Package procedures for Budget Inquiry form
--   This package contains several Set_xxxx(value) and
--   Get_xxxx(value) routines used to initialize and
--   retrieve certain database variables. The purpose
--   for these procedures and functions is to allow
--   outer joins in views from within SQL*Forms.
--
--   The variables being initialize correspond to the
--   selection criteria displayed in the first window
--   of the Budget Inquiry form. The user selects a budget
--   (budget_version_id), currency (currency_code),
--   summary template (template_id, optional), summary code
--   combination id (ccid) and units (factor). When the user
--   navigates to the balances window, these procedures are called
--   to first initialize the values, and then query the appropriate
--   rows.
-- History
--   18-OCT-94	E Wilson	Created
--
  --
  -- Procedure
  --   Set_Criteria
  -- Purpose
  --   Set the Selection Criteria for Budget Inquiry form
  -- Arguments
  --   value    budget version id
  --            template id
  --            factor
  --            code_combination_id
  --            currency_code
  --		functional currency code
  -- Example
  --   BUDGET_INQUIRY_PKG.Set_Bvid(budget_version_id,....)
  -- Notes
  --
  PROCEDURE set_criteria (X_budget_version_id     NUMBER,
                          X_template_id           NUMBER,
                          X_factor                NUMBER,
                          X_code_combination_id   NUMBER,
                          X_currency_code         VARCHAR2,
                          X_funct_curr            VARCHAR2);

  --
  -- Procedure
  --   Set_Ledger_Id
  -- Purpose
  --   Set the Selection Criteria for Budget Inquiry form
  --   accounting_flexfield block
  -- Arguments
  --   value    ledger_id
  -- Example
  --   BUDGET_INQUIRY_PKG.Set_Ledger_Id(ledger_id,....)
  -- Notes
  --
  PROCEDURE Set_Ledger_Id(X_ledger_id NUMBER);

  --
  -- Function
  --   Get_Ledger_Id
  -- Purpose
  --   Retrieve current value of ledger id
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_ledger_id;
  -- Notes
  --
  FUNCTION  Get_Ledger_Id RETURN NUMBER;

  --
  -- Function
  --   Get_Bvid
  -- Purpose
  --   Retrieve current value of budget version id
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Bvid;
  -- Notes
  --
  FUNCTION  Get_Bvid RETURN NUMBER;

  --
  -- Function
  --   Get_Currency
  -- Purpose
  --   Retrieve current value of currency code
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Currency;
  -- Notes
  --
  FUNCTION  Get_Currency RETURN VARCHAR2;

  --
  -- Function
  --   Get_Template_Id
  -- Purpose
  --   Retrieve current value of template id
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Template_Id;
  -- Notes
  --
  FUNCTION  Get_Template_Id RETURN NUMBER;

  --
  -- Function
  --   Get_Factor
  -- Purpose
  --   Retrieve current value of factor
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Factor;
  -- Notes
  --
  FUNCTION  Get_Factor  RETURN NUMBER;

  --
  -- Function
  --   Get_Funct_Curr
  -- Purpose
  --   Retrieve current value of functional currency
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Funct_Curr
  -- Notes
  --
  FUNCTION  Get_Funct_Curr  RETURN VARCHAR2;

  --
  -- Function
  --   Get_Ccid
  -- Purpose
  --   Retrieve current value of code combination id
  -- Arguments
  --   none
  -- Example
  --   BUDGET_INQUIRY_PKG.Get_Ccid;
  -- Notes
  --
  FUNCTION  Get_Ccid  RETURN NUMBER;

  --
  -- Procedure
  --   Check_Detail_Accounts
  -- Purpose
  --   Check to see if detail accounting flexfields exist for
  --   a particular summary account
  -- Arguments
  --   X_Code_Combination_Id    Summary account code combination id
  -- Example
  --   BUDGET_INQUIRY_PKG.Check_Detail_Accounts(summary_code_combination_id)
  -- Notes
  --
  PROCEDURE Check_Detail_Accounts(X_Code_Combination_Id  NUMBER);

  PRAGMA RESTRICT_REFERENCES(Set_Criteria, WNDS);
  PRAGMA RESTRICT_REFERENCES(Set_Ledger_Id, WNDS);
  PRAGMA RESTRICT_REFERENCES(Get_Ledger_Id, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Bvid, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Currency, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Template_Id, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Factor, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Funct_Curr, WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Get_Ccid, WNDS, WNPS);

END BUDGET_INQUIRY_PKG;

 

/
