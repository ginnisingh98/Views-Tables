--------------------------------------------------------
--  DDL for Package OKE_ACTION_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_ACTION_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEVDATS.pls 120.0 2005/05/25 17:30:58 appldev noship $ */

  FUNCTION Validate_MDS ( P_Action_ID		NUMBER
			, P_Deliverable_ID		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Schedule_Designator		VARCHAR2
			, P_Expected_Date		DATE
			, P_Quantity			NUMBER
			, P_Uom_Code			VARCHAR2 ) RETURN VARCHAR2;

  FUNCTION Validate_WSH ( P_Action_ID			NUMBER
			, P_Deliverable_ID		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Expected_Date		DATE
			, P_Volume			NUMBER
			, P_Volume_Uom			VARCHAR2
			, P_Weight			NUMBER
			, P_Weight_Uom			VARCHAR2
			, P_Quantity			NUMBER
			, P_Uom_Code			VARCHAR2 ) RETURN VARCHAR2;

  FUNCTION Validate_Req ( P_Action_ID			NUMBER
			, P_Deliverable_ID 		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Expected_Date		DATE
			, P_Destination_Type_Code	VARCHAR2
			, P_Requisition_Line_Type_ID	NUMBER
			, P_Category_ID			NUMBER
			, P_Currency_Code		VARCHAR2
			, P_Quantity			NUMBER
			, P_UOM_Code			VARCHAR2
			, P_Unit_Price			NUMBER
			, P_Rate_Type			VARCHAR2
			, P_Rate_Date			DATE
			, P_Exchange_Rate		NUMBER
			, P_Expenditure_Type_Code	VARCHAR2
			, P_Expenditure_Organization_Id	NUMBER
			, P_Expenditure_Item_Date	DATE )
RETURN VARCHAR2;

FUNCTION Exchange_Rate ( P_Orig_Code VARCHAR2
			, P_Target_Code VARCHAR2
			, P_Rate_Type VARCHAR2
			, P_Date DATE )
RETURN NUMBER;

FUNCTION Functional_Currency ( P_Org_ID NUMBER )
RETURN VARCHAR2;

FUNCTION Get_Location_Description ( P_ID NUMBER )
RETURN VARCHAR2;


PROCEDURE Add_Msg ( P_Action_ID	NUMBER
		, P_Msg	VARCHAR2 );



END;


 

/
