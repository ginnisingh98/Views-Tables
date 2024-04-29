--------------------------------------------------------
--  DDL for Package ASO_SHIPPING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SHIPPING_INT" AUTHID CURRENT_USER as
/* $Header: asoishps.pls 120.1 2005/06/29 12:35:50 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_SHIPPING_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   Record Type:
--	Charge_Control_Rec_Type

TYPE Charge_Control_Rec_Type IS RECORD
(
    Query_From_DB		VARCHAR2(1) := 'N'
);

G_Miss_Charge_Control_Rec  Charge_Control_Rec_Type;

FUNCTION Get_Total_Freight_Charges(p_qte_header_id NUMBER)
RETURN NUMBER;

PROCEDURE Calculate_Freight_Charges(
    P_Api_Version_Number	 IN   NUMBER,
    P_Charge_Control_Rec	 IN   Charge_Control_Rec_Type
					:= G_Miss_Charge_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Line_Rec,
    P_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    x_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

FUNCTION Get_line_Freight_charges(
	p_qte_header_id	 NUMBER := FND_API.G_MISS_NUM
	,p_qte_line_id	 NUMBER := FND_API.G_MISS_NUM )
RETURN number;

FUNCTION Get_Header_Freight_Charges(p_qte_header_id NUMBER)
RETURN NUMBER;


End ASO_SHIPPING_INT;

 

/
