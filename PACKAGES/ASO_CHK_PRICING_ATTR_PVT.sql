--------------------------------------------------------
--  DDL for Package ASO_CHK_PRICING_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CHK_PRICING_ATTR_PVT" AUTHID CURRENT_USER as
/* $Header: asovpatrs.pls 120.1 2005/06/29 12:42:56 appldev noship $ */
-- Start of Comments
--
-- NAME
--   ASO_CHK_PRICING_ATTR_PVT
--
-- PURPOSE
--   This package is a public utility API developed from Sales Core group
--
--   Constants:
--
--
--   Procedures:
--         Check_Pricing_Attributes
-- NOTES
--
--
-- HISTORY
--
--
-- End of Comments

PROCEDURE Check_Pricing_Attributes (
	 P_Api_Version_Number         	IN   NUMBER         := 1,
	 P_Init_Msg_List              	IN   VARCHAR2     	:= FND_API.G_FALSE,
	 P_Commit                     	IN   VARCHAR2     	:= FND_API.G_FALSE,
	 P_Inventory_Id				IN	NUMBER         := FND_API.G_MISS_NUM,
	 P_Quote_Line_Id				IN	NUMBER         := FND_API.G_MISS_NUM,
	 P_Price_List_Id				IN	NUMBER         := FND_API.G_MISS_NUM,
	 X_Check_Return_Status_qp	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	 X_Check_Return_Status_aso         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	 x_msg_count         		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	 x_msg_data         		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2);



End ASO_CHK_PRICING_ATTR_PVT;

 

/
