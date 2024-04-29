--------------------------------------------------------
--  DDL for Package ENG_ECO_PRIOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_PRIOR_PKG" AUTHID CURRENT_USER as
/* $Header: engpecps.pls 115.2 2003/02/07 09:06:33 rbehal ship $ */

PROCEDURE CHECK_UNIQUE(
	X_Org_id	NUMBER,
	X_Priority_code VARCHAR2);

PROCEDURE CHECK_REFERENCES(
	X_Org_id	NUMBER,
	X_Priority_code VARCHAR2);

END ENG_ECO_PRIOR_PKG ;

 

/
