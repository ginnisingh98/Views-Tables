--------------------------------------------------------
--  DDL for Package ASO_QUOTE_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_LINES_PVT" AUTHID CURRENT_USER as
/* $Header: asovqlns.pls 120.1 2005/06/29 12:43:58 appldev ship $ */
-- Start of Comments
-- Start of Comments
-- Package name     : ASO_QUOTE_LINES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--Fix performance bug for literals
G_PROMO_GOODS_DISCOUNT CONSTANT VARCHAR2(30) := 'PRG';
G_DISCOUNT             CONSTANT VARCHAR2(30) := 'DIS';

-- this procedure calls the table handlers to insert the rows.

PROCEDURE Insert_Quote_Line_Rows(
P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_tbl,
    P_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl  IN    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl        IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl       IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl       IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
                                 := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                  := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_Tbl OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl  OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl        OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Lines
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Details_Tbl      IN    Tax_Details_Tbl_Type
--       P_Freight_Charges_Tbl  IN    Freight_Charges_Tbl_Type
--       P_Line_Relationship_Tbl IN   Line_Relationship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Relationship_Tbl IN Price_Adj_Relationship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE

--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */  NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Quote_Lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List    IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec   IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_TBL IN    ASO_QUOTE_PUB.Qte_Line_Dtl_TBL_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl  IN    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl        IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl       IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl       IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
                                  := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag         IN   VARCHAR2   := 'Y',
    X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_Tbl OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl   OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl        OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Details_Tbl      IN    Tax_Details_Tbl_Type
--       P_Freight_Charges_Tbl  IN    Freight_Charges_Tbl_Type
--       P_Line_Relationship_Tbl IN   Line_Relationship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Relationship_Tbl IN Price_Adj_Relationship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE
--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */  NUMBER,
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

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List    IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec   IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_Tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl  IN    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl        IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl       IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl       IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
                                 := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag         IN   VARCHAR2   := 'Y',
    X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_Tbl OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl  OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl        OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_line_Rec      IN qte_line_Rec_Type  Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
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

PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN    ASO_QUOTE_PUB.qte_line_Rec_Type,
    P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Update_Header_Flag         IN   VARCHAR2   := 'Y',
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Quote_Lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_quote_id                IN   NUMBER     Required
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
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       X_qte_line_Tbl     OUT NOCOPY /* file.sql.39 change */  qte_line_Tbl_Type
--       X_Payment_Tbl       OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type
--       X_Price_Adj_Tbl     OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type
--       X_Qte_Line_Dtl_Tbl  OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type
--       X_Shipment_Tbl      OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type
--       X_Tax_Details_Tbl   OUT NOCOPY /* file.sql.39 change */  Tax_Details_Tbl_Type
--       X_Freight_Charges_Tbl OUT NOCOPY /* file.sql.39 change */ Freight_Charges_Tbl_Type
--       X_Line_Relationship_Tbl OUT NOCOPY /* file.sql.39 change */ Line_Relationship_Tbl_Type
--       X_Related_Object_Tbl OUT NOCOPY /* file.sql.39 change */   Related_Object_Tbl_Type
--       X_Price_Attributes_Tbl   OUT NOCOPY /* file.sql.39 change */    Price_Attributes_Tbl_Type
--       X_Price_Adj_Relationship_Tbl OUT NOCOPY /* file.sql.39 change */ Price_Adj_relationship_Tbl_Type
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
PROCEDURE Get_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
     p_order_by_rec               IN   ASO_QUOTE_PUB.qte_line_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
    P_Qte_Line_Rec     		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC      		 IN   ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_Rec OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Line_Rltship_Tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_rltship_Tbl OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
    );

Procedure SERVICE_ITEM_QTY_UPDATE
 (p_qte_line_rec  IN ASO_QUOTE_PUB.QTE_LINE_REC_TYPE,
  p_service_item_flag  IN VARCHAR2,
  x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 );


End ASO_QUOTE_LINES_PVT;

 

/
