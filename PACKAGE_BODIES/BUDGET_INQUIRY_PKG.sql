--------------------------------------------------------
--  DDL for Package Body BUDGET_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BUDGET_INQUIRY_PKG" AS
/* $Header: gliiqbdb.pls 120.2 2003/04/24 01:29:08 djogg ship $ */
--
-- PUBLIC VARIABLES
--

budget_version_id    NUMBER;
template_id          NUMBER;
factor               NUMBER;
code_combination_id  NUMBER;
ledger_id	     NUMBER;

period_name          VARCHAR2(15);
currency_code        VARCHAR2(15);
funct_curr	     VARCHAR2(15);

--
-- PUBLIC PROCEDURES
--
PROCEDURE set_criteria(X_budget_version_id  	NUMBER,
			X_template_id		NUMBER,
			X_factor		NUMBER,
			X_code_combination_id	NUMBER,
			X_currency_code		VARCHAR2,
			X_funct_curr		VARCHAR2) IS
BEGIN
   BUDGET_INQUIRY_PKG.budget_version_id 		:= X_budget_version_id;
   BUDGET_INQUIRY_PKG.template_id 			:= X_template_id;
   BUDGET_INQUIRY_PKG.factor 				:= X_factor;
   BUDGET_INQUIRY_PKG.currency_code 			:= X_currency_code;
   BUDGET_INQUIRY_PKG.code_combination_id 		:= X_code_combination_id;
   BUDGET_INQUIRY_PKG.funct_curr			:= X_funct_curr;
END set_criteria;

PROCEDURE Set_Ledger_Id(X_ledger_id NUMBER) IS
BEGIN
   BUDGET_INQUIRY_PKG.ledger_id 			:= X_ledger_id;
END Set_Ledger_Id;

FUNCTION Get_Ledger_Id RETURN NUMBER IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.ledger_id;
END Get_Ledger_Id;

FUNCTION Get_Bvid RETURN NUMBER IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.budget_version_id;
END Get_Bvid;

FUNCTION Get_Template_Id RETURN NUMBER IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.template_id;
END Get_Template_Id;

FUNCTION Get_Factor RETURN NUMBER IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.factor;
END Get_Factor;

FUNCTION Get_Currency RETURN VARCHAR2 IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.currency_code;
END Get_Currency;

FUNCTION Get_Funct_Curr RETURN VARCHAR2 IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.funct_curr;
END Get_Funct_Curr;

PROCEDURE Set_Period(value  VARCHAR2) IS
BEGIN
   BUDGET_INQUIRY_PKG.period_name := value;
END Set_Period;

FUNCTION Get_Period RETURN VARCHAR2 IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.period_name;
END Get_Period;

FUNCTION Get_Ccid RETURN NUMBER IS
BEGIN
  RETURN BUDGET_INQUIRY_PKG.code_combination_id;
END Get_Ccid;

PROCEDURE Check_Detail_Accounts(X_Code_Combination_Id  NUMBER) IS

CURSOR C1 IS
  SELECT  1
    FROM  GL_ACCOUNT_HIERARCHIES
   WHERE  SUMMARY_CODE_COMBINATION_ID = X_Code_Combination_Id;

dummy  NUMBER;

BEGIN
  OPEN C1;
  FETCH C1 INTO dummy;

  IF C1%NOTFOUND THEN
    CLOSE C1;
    fnd_message.set_name('SQLGL','GL_NO_CHILD_ACCOUNTS');
    app_exception.raise_exception;
  END IF;

  CLOSE C1;
END Check_Detail_Accounts;

END BUDGET_INQUIRY_PKG;

/
