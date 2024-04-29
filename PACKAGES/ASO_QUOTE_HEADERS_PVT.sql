--------------------------------------------------------
--  DDL for Package ASO_QUOTE_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_HEADERS_PVT" AUTHID CURRENT_USER as
/* $Header: asovqhds.pls 120.3.12010000.1 2008/07/28 22:19:42 appldev ship $ */
-- Package name     : ASO_QUOTE_HEADERS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

-- hyang defaulting framework
G_QUOTE_HEADER_DB_NAME        CONSTANT VARCHAR2(30) := 'ASO_AK_QUOTE_HEADER_V';
G_QUOTE_LINE_DB_NAME          CONSTANT VARCHAR2(30) := 'ASO_AK_QUOTE_LINE_V';
G_QUOTE_OPPORTUNITY_DB_NAME   CONSTANT VARCHAR2(30) := 'ASO_AK_QUOTE_OPPTY_V';
G_STORE_CART_HEADER_DB_NAME   CONSTANT VARCHAR2(30) := 'ASO_AK_STORE_CART_HEADER_V';
G_STORE_CART_LINE_DB_NAME     CONSTANT VARCHAR2(30) := 'ASO_AK_STORE_CART_LINES_V';
-- hyang defaulting framework end

TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY VARCHAR2(32767);
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;

TYPE Instance_Rec_Type IS RECORD
(
    Instance_id        NUMBER,
    Price_List_Id      NUMBER := FND_API.G_MISS_NUM
);
G_MISS_Instance_Rec    Instance_Rec_Type;

TYPE Instance_Tbl_Type IS TABLE OF Instance_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_Instance_Tbl    Instance_Tbl_Type;

TYPE VARCHAR_Tbl_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Qte_Header_Rec     IN ASO_QUOTE_PUB.Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		 IN   ASO_QUOTE_PUB.Control_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec	         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl,
    P_ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   ASO_QUOTE_PUB.Template_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   ASO_QUOTE_PUB.Related_Obj_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Shipment_Rec_Type,
    X_hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
     X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
      X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Related_Obj_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN ASO_QUOTE_PUB.Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.

PROCEDURE Update_quote(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Commit			 IN   VARCHAR2	   := FND_API.G_FALSE,
    p_validation_level		 IN   NUMBER	   := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		 IN   ASO_QUOTE_PUB.Control_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
     P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
     P_hd_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                    := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                        := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl,
    P_ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                        := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                        := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   ASO_QUOTE_PUB.Template_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   ASO_QUOTE_PUB.Related_Obj_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_hd_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Related_Obj_Tbl_Type,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN ASO_QUOTE_PUB.Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Copy_quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Copy_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
	P_control_rec         IN  ASO_QUOTE_PUB.control_rec_type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_New_Version		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Status_Id		 IN   NUMBER	   := NULL,
    P_Qte_Number		 IN   NUMBER	   := NULL,
    X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Validate_Quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Validate_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Submit_Quote
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec		 IN   ASO_QUOTE_PUB.SUBMIT_CONTROL_REC_TYPE
			:=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Order_Header_Rec		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_quote
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN ASO_QUOTE_PUB.Qte_Header_Rec_Type  Required
--   Hint: Add List of bind variables here
--       p_rec_requested           IN   NUMBER     Optional  Default = 30
--       p_start_rec_ptr           IN   NUMBER     Optional  Default = 1
--
--       Return Total Records Count Flag. This flag controls whether the total record count
--       and total record amount is returned.
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   Hint: User defined record type
--       p_order_by_tbl            IN   AS_UTILITY_PUB.UTIL_ORDER_BY_TBL_TYPE;
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       X_Qte_Header_Tbl     OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type
--       x_returned_rec_count      OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_next_rec_ptr            OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_tot_rec_count           OUT NOCOPY /* file.sql.39 change */   NUMBER
--  other optional OUT NOCOPY /* file.sql.39 change */ parameters
--       x_tot_rec_amount          OUT NOCOPY /* file.sql.39 change */   NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec		 IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   ASO_QUOTE_PUB.QTE_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Qte_Header_Tbl		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Header_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */     NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY /* file.sql.39 change */    NUMBER
    );

PROCEDURE Update_Quote_Total (
    P_Qte_Header_id		IN	NUMBER,
    P_Calculate_Tax		IN	VARCHAR2,
    P_calculate_Freight_Charge  IN	VARCHAR2,
    p_control_rec		 IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE
			:=  ASO_QUOTE_PUB.G_MISS_CONTROL_REC,
    P_Call_Ar_Api_Flag          IN   VARCHAR2 := FND_API.G_FALSE,
    X_Return_Status             OUT NOCOPY /* file.sql.39 change */   	VARCHAR2,
    X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */   	NUMBER,
    X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */   	VARCHAR2);


PROCEDURE config_copy(
   p_qte_line_id  IN  NUMBER,
   p_old_config_header_id IN NUMBER,
   p_old_config_revision_num IN NUMBER,
   p_config_header_id IN NUMBER,
   p_config_revision_num IN NUMBER,
   x_qte_header_id IN NUMBER,
   qte_header_id IN NUMBER,
   p_qte_line_rec IN ASO_QUOTE_PUB.Qte_Line_Rec_Type,
      p_control_rec IN  ASO_QUOTE_PUB.CONTROL_REC_TYPE := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   l_line_index_link_tbl  IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   l_price_index_link_tbl  IN OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
   X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
 );

PROCEDURE service_copy(
   p_qte_line_id        IN   NUMBER,
   x_qte_header_id      IN NUMBER,
   qte_header_id        IN NUMBER,
   p_qte_line_rec       IN ASO_QUOTE_PUB.Qte_Line_Rec_Type,
   P_control_rec        IN  ASO_QUOTE_PUB.control_rec_type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   l_line_index_link_tbl    IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   l_price_index_link_tbl   IN OUT NOCOPY   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   X_Return_Status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
   X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */     NUMBER,
   X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

PROCEDURE Quote_Security_Check(
    P_Api_Version_Number         IN      NUMBER,
    P_Init_Msg_List              IN      VARCHAR2     := FND_API.G_FALSE,
    P_User_Id                    IN      NUMBER,
    X_Resource_Id                OUT NOCOPY /* file.sql.39 change */        NUMBER,
    X_Security_Flag              OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */        NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);
PROCEDURE Insert_Rows (
    P_qte_Header_Rec		 IN   ASO_QUOTE_PUB.qte_header_rec_Type,
    p_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_Sales_Credit_Tbl           IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_Quote_Party_Tbl            IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_header_rec_Type,
    X_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    x_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Shipment_Rec_Type,
    X_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_Sales_Credit_Tbl           OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl            OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    x_Qte_Access_Tbl      OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

FUNCTION  Shipment_Null_Rec_Exists(
  p_shipment_rec          IN  ASO_QUOTE_PUB.Shipment_Rec_Type,
  p_database_object_name  IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION  Payment_NULL_Rec_Exists(
  p_payment_rec           IN  ASO_QUOTE_PUB.Payment_Rec_Type,
  p_database_object_name  IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION  Tax_Detail_Null_Rec_Exists(
  p_tax_detail_rec        IN  ASO_QUOTE_PUB.Tax_Detail_Rec_Type,
  p_database_object_name  IN VARCHAR2
) RETURN BOOLEAN;


End ASO_QUOTE_HEADERS_PVT;

/
