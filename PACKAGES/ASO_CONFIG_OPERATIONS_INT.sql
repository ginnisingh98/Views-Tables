--------------------------------------------------------
--  DDL for Package ASO_CONFIG_OPERATIONS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CONFIG_OPERATIONS_INT" AUTHID CURRENT_USER as
/* $Header: asoicfos.pls 120.2 2005/11/18 14:58:40 bmishra ship $ */

PROCEDURE config_operations(
   	P_Api_Version_Number  	IN	  NUMBER,
    P_Init_Msg_List   		IN	  VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		    IN	  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level   	IN	  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		    IN	  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_qte_line_tbl          IN	  ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl ,
    P_instance_tbl          IN    ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
    p_operation_code        IN    VARCHAR2,
    p_delete_flag           IN    VARCHAR2  := FND_API.G_TRUE,
    x_Qte_Header_Rec        OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

END ASO_CONFIG_OPERATIONS_INT;

 

/
