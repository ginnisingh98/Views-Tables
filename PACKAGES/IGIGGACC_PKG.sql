--------------------------------------------------------
--  DDL for Package IGIGGACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIGGACC_PKG" AUTHID CURRENT_USER as
-- $Header: igibudhs.pls 120.2 2005/10/30 05:57:52 appldev ship $
average_unbalanced varchar2(1);
balanced_budget_flag varchar2(1);
bud_status_flag    varchar2(1);

PROCEDURE set_profile (X_average_unbalanced	varchar2,
	               X_balanced_budget_flag   varchar2,
                       X_bud_status_flag        varchar2
		      );

FUNCTION  get_average_unbalanced return varchar2;
PRAGMA    RESTRICT_REFERENCES(get_average_unbalanced,WNDS,WNPS);
FUNCTION  get_balanced_budget_flag return varchar2;
PRAGMA    RESTRICT_REFERENCES(get_balanced_budget_flag,WNDS,WNPS);
FUNCTION  get_bud_status_flag return varchar2;
PRAGMA    RESTRICT_REFERENCES(get_bud_status_flag,WNDS,WNPS);
END IGIGGACC_PKG;



/
