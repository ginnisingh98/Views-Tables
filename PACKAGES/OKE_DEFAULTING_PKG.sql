--------------------------------------------------------
--  DDL for Package OKE_DEFAULTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DEFAULTING_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEVLTDS.pls 120.1.12000000.1 2007/01/17 06:54:20 appldev ship $ */

  G_Api_Type  CONSTANT VARCHAR2(4) := '_PKG';
  G_Pkg_Name  CONSTANT VARCHAR2(200) := 'OKE_DEFAULTING';
  G_App_Name  CONSTANT VARCHAR2(200) := OKE_API.G_App_Name;
  G_False     CONSTANT VARCHAR2(1)   := 'F';

  SUBTYPE Del_Rec_Type IS OKE_DELIVERABLE_PVT.Del_Rec_Type;
  SUBTYPE Del_Tbl_Type IS OKE_DELIVERABLE_PVT.Del_Tbl_Type;

  PROCEDURE Default_Deliverables (
    P_Api_Version		IN NUMBER DEFAULT 1
  , P_Init_Msg_List		IN VARCHAR2 DEFAULT G_False
  , P_Update_Yn			IN VARCHAR2 DEFAULT 'N'
  , P_Header_ID			IN NUMBER
  , P_Line_ID			IN NUMBER
  , X_Return_Status		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , X_Counter			OUT NOCOPY NUMBER );

  PROCEDURE Create_New_L (
    P_Initiate_Msg_List IN VARCHAR2 DEFAULT G_False
  , X_Return_Status		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , P_Header_ID			IN NUMBER
  , P_Line_ID			IN NUMBER
  , P_Direction			IN VARCHAR2
  , P_Inventory_Org_ID		IN NUMBER
  , X_Counter			OUT NOCOPY NUMBER);

  PROCEDURE Create_New (
    P_Init_Msg_List VARCHAR2 DEFAULT G_False
  , X_Return_Status 		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , P_Header_ID			IN  NUMBER
  , P_Direction			IN  VARCHAR2
  , P_Inventory_Org_ID		IN  NUMBER
  , X_Counter			OUT NOCOPY NUMBER);

  PROCEDURE Update_Line(
    P_Init_Msg_List VARCHAR2 DEFAULT G_False
  , X_Return_Status 		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , P_Header_ID			IN  NUMBER
  , P_Line_ID			IN  NUMBER
  , P_Direction			IN  VARCHAR2
  , P_Inventory_Org_ID		IN  NUMBER
  , X_Counter			OUT NOCOPY NUMBER);

  PROCEDURE Update_Batch (
    P_Init_Msg_List VARCHAR2 DEFAULT G_False
  , X_Return_Status 		OUT NOCOPY VARCHAR2
  , X_Msg_Count			OUT NOCOPY NUMBER
  , X_Msg_Data			OUT NOCOPY VARCHAR2
  , P_Header_ID			IN  NUMBER
  , P_Direction			IN  VARCHAR2
  , P_Inventory_Org_ID		IN  NUMBER
  , X_Counter			OUT NOCOPY NUMBER);

  PROCEDURE Get_Org (
    P_Header_ID			IN NUMBER
  , P_Line_ID			IN NUMBER
  , X_Ship_To_ID		OUT NOCOPY NUMBER
  , X_Ship_From_ID		OUT NOCOPY NUMBER);

  PROCEDURE Verify_Defaults (
    P_Line_ID			IN NUMBER
  , X_Msg_1			OUT NOCOPY VARCHAR2
  , X_Msg_2			OUT NOCOPY VARCHAR2
  , X_Msg_3			OUT NOCOPY VARCHAR2
  , X_Return_Status		OUT NOCOPY VARCHAR2
  , P_Calling_Level		IN VARCHAR2 DEFAULT 'L');

  PROCEDURE Convert_Value(P_Header_ID 		NUMBER
		  	, P_Line_ID 		NUMBER
			, P_Direction 		VARCHAR2
			, X_Ship_To_Org_ID 	OUT NOCOPY NUMBER
			, X_Ship_To_ID 		OUT NOCOPY NUMBER
			, X_Ship_From_Org_ID 	OUT NOCOPY NUMBER
			, X_Ship_From_ID 	OUT NOCOPY NUMBER
			, X_Inv_Org_ID 		OUT NOCOPY NUMBER);

  FUNCTION Check_Mps_Valid( P_Line_ID NUMBER, X_Mps_S OUT NOCOPY VARCHAR2, X_Mps_F OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;

END;


 

/
