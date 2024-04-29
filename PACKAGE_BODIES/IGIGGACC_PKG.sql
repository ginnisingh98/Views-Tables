--------------------------------------------------------
--  DDL for Package Body IGIGGACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIGGACC_PKG" as
-- $Header: igibudhb.pls 120.2 2005/10/30 05:57:50 appldev ship $
PROCEDURE set_profile(X_average_unbalanced   	varchar2,
		      X_balanced_budget_flag	varchar2,
                      X_bud_status_flag         varchar2) IS

BEGIN
	IGIGGACC_PKG.average_unbalanced := X_average_unbalanced;
        IGIGGACC_PKG.balanced_budget_flag :=X_balanced_budget_flag;
        IGIGGACC_PKG.bud_status_flag     := X_bud_status_flag;
END set_profile;

FUNCTION  get_average_unbalanced return varchar2 is
BEGIN
  RETURN IGIGGACC_PKG.average_unbalanced;
END get_average_unbalanced;

FUNCTION get_balanced_budget_flag return varchar2 is
BEGIN
  RETURN IGIGGACC_PKG.balanced_budget_flag;
END get_balanced_budget_flag;

FUNCTION get_bud_status_flag return varchar2 is
BEGIN
  RETURN IGIGGACC_PKG.bud_status_flag;
END get_bud_status_flag;
end IGIGGACC_PKG;


/
