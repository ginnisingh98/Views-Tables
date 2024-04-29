--------------------------------------------------------
--  DDL for Package AP_AUTO_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AUTO_PAYMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: apautops.pls 120.3.12010000.2 2009/02/20 13:42:31 dawasthi ship $ */

--Bugfix 2124107 - Add one more parameter p_last_update_login

  PROCEDURE Replace_Check
		(P_Old_Check_Id         IN      NUMBER
		,P_Replace_Check_Id     IN OUT NOCOPY  NUMBER
		,P_Replace_Check_Date   IN 	DATE
		,P_Replace_Period_Name  IN      VARCHAR2
		,P_Replace_Check_Num    IN 	NUMBER
		,P_Replace_Voucher_Num 	IN 	NUMBER
		,P_Orig_Amount          IN 	NUMBER
		,P_Orig_payment_Date    IN 	DATE
		,P_Last_Updated_By     	IN 	NUMBER
		,P_Future_Pay_Ccid 	IN 	NUMBER
		,P_Quickcheck_Id       	IN 	VARCHAR2
		,P_Calling_Sequence     IN 	VARCHAR2
		,P_Last_Update_Login    IN      NUMBER    DEFAULT NULL
		,P_Remit_to_supplier_name    IN VARCHAR2 DEFAULT NULL --Bug 8218410
		,P_Remit_to_supplier_id      IN Number DEFAULT NULL
		,P_Remit_To_Supplier_Site    IN	VARCHAR2 DEFAULT NULL
		,P_Remit_To_Supplier_Site_Id IN	NUMBER DEFAULT NULL
		,P_Relationship_Id	     IN	NUMBER DEFAULT NULL --Bug 8218410 ends
		);

  --Bug 5061811 - remove  obsoleted procedure INSERT_TEMP_RECORDS
  --PROCEDURE Insert_Temp_Records
  --		(P_Check_Id         IN NUMBER
  --		,P_Calling_Sequence IN VARCHAR2
  --		);

  FUNCTION Selection_Criteria_Exists(P_Check_Id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(Selection_Criteria_Exists, WNDS, WNPS, RNPS);

  FUNCTION Get_Check_Stock_In_Use_By(p_check_stock_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(Get_Check_Stock_In_Use_By, WNDS, WNPS, RNPS);

  FUNCTION OK_To_Call_Withholding(P_Invoice_Id IN NUMBER) RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(OK_To_Call_Withholding, WNDS, WNPS, RNPS);

END AP_AUTO_PAYMENT_PKG;

/
