--------------------------------------------------------
--  DDL for Package FII_BUDGET_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_BUDGET_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIBUINS.pls 120.5 2005/10/30 05:07:40 appldev noship $ */

--
-- PUBLIC VARIABLES
--

--
-- PUBLIC PROCEDURES

  --
  -- Procedure
  --   	Web_Adi_Upload
  -- Purpose
  --   	This is the routine called by Web ADI for uploading records
  --    into FII_BUDGET_INTERFACE
  -- History
  --   	07-22-02	 S Kung	        Created
  -- Arguments
  --    All columns in the FII_BUDGET_INTERFACE table
  -- Example
  --    FII_BUDGET_INTERFACE.Web_Adi_Upload;
  -- Notes
  --
 FUNCTION Web_Adi_Upload
		( X_RowID		IN	VARCHAR2 DEFAULT NULL,
		  X_Plan_Type		IN	VARCHAR2,
		  X_Version_Date IN VARCHAR2 DEFAULT NULL,
		  X_Time_Period		IN	VARCHAR2 DEFAULT NULL,
		  X_Date		IN	DATE DEFAULT NULL,
		  X_Company     IN  VARCHAR2 DEFAULT NULL,
          X_Cost_Center IN  VARCHAR2 DEFAULT NULL,
		  X_CCC			IN	NUMBER DEFAULT NULL,
		  X_LOB			IN	VARCHAR2 DEFAULT NULL,
		  X_Acct		IN	VARCHAR2 DEFAULT NULL,
		  X_Fin_Item		IN	VARCHAR2 DEFAULT NULL,
		  X_Product		IN	NUMBER DEFAULT NULL,
		  X_User_Defined_Dim IN VARCHAR2 DEFAULT NULL,
		  X_Prim_Amt		IN	NUMBER,
 		  X_Rate		IN	NUMBER DEFAULT NULL,
		  X_Sec_Amt		IN	NUMBER DEFAULT NULL,
		  X_Ledger      IN  NUMBER DEFAULT NULL
          ) return VARCHAR2;

END FII_BUDGET_INTERFACE_PKG;


 

/
