--------------------------------------------------------
--  DDL for Package ASO_TRADEIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_TRADEIN_PVT" AUTHID CURRENT_USER as
/* $Header: asovtrds.pls 120.1 2005/06/29 12:45:33 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_TRADEIN_PVT
-- Purpose          :
--
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Validate_Line_Tradein(
	p_init_msg_list      IN   VARCHAR2,
	p_qte_header_rec	 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Rec		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
	x_return_status      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count          OUT NOCOPY /* file.sql.39 change */    NUMBER,
	x_msg_data           OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE OrderType(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec	IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);


PROCEDURE LineType(
	p_init_msg_list		IN	VARCHAR2,
    p_qte_header_rec IN OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_qte_line_rec	    IN OUT NOCOPY   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);


PROCEDURE Add_Lines_from_InstallBase(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec         IN   ASO_QUOTE_PUB.Control_Rec_Type
     				:= ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
     				:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_instance_tbl        IN   ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type
					:= ASO_QUOTE_HEADERS_PVT.G_MISS_Instance_Tbl,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl        OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_ln_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE Validate_IB_Return_Qty(
            p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
            p_Qte_Line_rec       IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
            p_Qte_Line_Dtl_Tbl   IN   ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type,
            x_return_status      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
            x_msg_count          OUT NOCOPY /* file.sql.39 change */    NUMBER,
            x_msg_data           OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


END ASO_TRADEIN_PVT;

 

/
