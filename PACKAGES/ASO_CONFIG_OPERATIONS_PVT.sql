--------------------------------------------------------
--  DDL for Package ASO_CONFIG_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CONFIG_OPERATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: asovcfos.pls 120.2 2005/11/18 14:58:05 bmishra ship $ */

PROCEDURE Add_to_Container_from_IB(
   	P_Api_Version_Number    IN  NUMBER,
    P_Init_Msg_List         IN	VARCHAR2    := FND_API.G_FALSE,
    P_Commit                IN  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level   	IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec           IN  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Quote_line_Id         IN	NUMBER,
    P_instance_tbl          IN	ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
    x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data    	        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


PROCEDURE Reconfigure_from_IB(
   	P_Api_Version_Number  	IN	NUMBER,
    P_Init_Msg_List   		IN	VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		    IN	VARCHAR2    := FND_API.G_FALSE,
   	p_validation_level   	IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		    IN	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_instance_tbl          IN	ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
    x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


PROCEDURE Deactivate_from_quote(
   	P_Api_Version_Number  	IN	NUMBER,
    P_Init_Msg_List   		IN	VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		    IN	VARCHAR2    := FND_API.G_FALSE,
   	p_validation_level   	IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type :=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Control_Rec  		    IN	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
	P_qte_line_tbl          IN	ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl,
	p_delete_flag            IN  VARCHAR2 := FND_API.G_TRUE,
    x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

End ASO_CONFIG_OPERATIONS_PVT;

 

/
