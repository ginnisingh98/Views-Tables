--------------------------------------------------------
--  DDL for Package B_DEPT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."B_DEPT_CLASS_PKG" AUTHID CURRENT_USER as
/* $Header: bompbdcs.pls 115.1 99/07/16 05:47:24 porting ship $ */

PROCEDURE Check_Unique(X_Org_Id NUMBER,
		       X_Department_Class_Code VARCHAR2);

PROCEDURE Check_References(X_Org_Id NUMBER,
		           X_Department_Class_Code VARCHAR2);

END B_DEPT_CLASS_PKG;

 

/
