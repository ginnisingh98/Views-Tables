--------------------------------------------------------
--  DDL for Package ASO_SUBMIT_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUBMIT_QUOTE_PVT" AUTHID CURRENT_USER as
/* $Header: asovsubs.pls 120.1.12000000.2 2007/02/01 20:48:32 gkeshava ship $ */
-- Package name     : ASO_SUBMIT_QUOTE_PVT
-- Purpose          :
-- History          :
--			02/01/2007	gkeshava - Fix for perf bug 5714535
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Private
--   Pre-Req :
--
--   End of Comments
--

PROCEDURE Submit_Quote
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec		 IN   ASO_QUOTE_PUB.SUBMIT_CONTROL_REC_TYPE
			                             :=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Order_Header_Rec	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


FUNCTION Query_Tax_Detail_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM,
    P_Shipment_Tbl_Cnt   IN  NUMBER,
    P_Line_Index         IN  NUMBER,
    lx_tax_detail_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;


FUNCTION Query_Shipment_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_shipment_tbl      IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN VARCHAR2;


FUNCTION Query_Freight_Charge_Rows (
    P_Shipment_Tbl       IN  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Line_Index         IN  NUMBER,
    lx_freight_charge_tbl  IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;


FUNCTION  Query_Sales_Credit_Row (
    P_qte_header_Id       IN   NUMBER,
    P_qte_line_id         IN   NUMBER,
    P_Line_Index          IN   NUMBER,
    lx_sales_credit_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_tbl_Type
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_tbl_Type;


FUNCTION  Query_Quote_Party_Row (
    P_Qte_header_Id       IN   NUMBER,
    P_Qte_line_Id         IN   NUMBER,
    P_Line_Index          IN   NUMBER,
    lx_quote_party_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;


FUNCTION Query_Line_Dtl_Rows (
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_Line_Dtl_tbl      IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    ) RETURN VARCHAR2;


FUNCTION Query_Line_Attribs_Ext_Rows(
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_Line_Attr_Ext_Tbl IN OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;


FUNCTION Query_Price_Attr_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM,
    P_Line_Index         IN  NUMBER,
    lx_price_attr_tbl    IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;


FUNCTION Query_Price_Adj_Rltship_Rows (
    P_Price_Adjustment_Id     IN  NUMBER,
    P_Line_Index              IN  NUMBER,
    lx_price_adj_rltd_tbl     IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;


FUNCTION Query_Price_Adj_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Rec       IN  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Line_Index         IN  NUMBER,
    Lx_price_adj_rltship_tbl  IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    Lx_price_adj_tbl          IN OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type
    ) RETURN VARCHAR2;


FUNCTION Query_Price_Adj_Hdr_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type;


PROCEDURE Raise_Quote_Event(
    P_Quote_Header_id       IN      NUMBER,
    P_Control_Rec           IN      ASO_QUOTE_PUB.SUBMIT_Control_Rec_Type
                                        :=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2 );


PROCEDURE Quote_Order_High_Availability(
     P_Quote_Header_Id        IN   NUMBER,
     P_Book_Flag              IN   VARCHAR2,
     P_Calculate_Flag         IN   VARCHAR2,
     P_Server_Id              IN   NUMBER,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


End ASO_SUBMIT_QUOTE_PVT;

 

/
