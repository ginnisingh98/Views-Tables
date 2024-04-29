--------------------------------------------------------
--  DDL for Package ASO_ORDER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_INT" AUTHID CURRENT_USER as
/* $Header: asoiords.pls 120.3 2005/06/30 13:55:42 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_ORDER_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Order_Header_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    order_number
--    header_id
--    status

--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Order_Header_Rec_Type IS RECORD
(
       ORDER_NUMBER          NUMBER := FND_API.G_MISS_NUM,
       ORDER_HEADER_ID       NUMBER := FND_API.G_MISS_NUM,
       QUOTE_HEADER_ID       NUMBER := FND_API.G_MISS_NUM,
       STATUS                VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_Order_Header_Rec    Order_Header_Rec_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Order_Line_Rec_Type
--   -------------------------------------------------------
--   Parameters:

--    header_id
--    line_id
--    status

--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Order_Line_Rec_Type IS RECORD
(
       ORDER_LINE_ID         NUMBER := FND_API.G_MISS_NUM,
       ORDER_HEADER_ID       NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_LINE_ID NUMBER := FND_API.G_MISS_NUM,
       STATUS                VARCHAR2(150) := FND_API.G_MISS_CHAR
);


G_MISS_Order_Line_Rec      Order_Line_Rec_Type;
TYPE Order_Line_Tbl_type    IS TABLE OF Order_Line_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Order_Line_Tbl      Order_Line_Tbl_Type;



TYPE FULFILLMENT_REC_TYPE IS RECORD
  (QUOTE_LINE_INDEX		NUMBER);

TYPE FULFILLMENT_TBL_TYPE IS TABLE OF FULFILLMENT_REC_TYPE
                           INDEX BY BINARY_INTEGER;
G_MISS_Fulfillment_tbl FULFILLMENT_TBL_TYPE;


TYPE Control_Rec_Type IS RECORD
(
      BOOK_FLAG           VARCHAR2(1) := FND_API.G_TRUE,
   --   RESERVE_FLAG      VARCHAR2(1) := FND_API.G_FALSE,
      CALCULATE_PRICE     VARCHAR2(1) := FND_API.G_FALSE,
      SERVER_ID           NUMBER      := -1 ,
      INTERFACE_FFM_FLAG  VARCHAR2(1) := FND_API.G_TRUE,
	 CC_BY_FAX           VARCHAR2(1) := FND_API.G_FALSE
);


G_MISS_Control_Rec      Control_Rec_Type;


TYPE order_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      ORDER_HEADER_ID   NUMBER := NULL
);



--  Line_Scredit record type

TYPE Sales_credit_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   dw_update_advice_flag         VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   quote_header_id                     NUMBER         := FND_API.G_MISS_NUM
,   quote_line_id                       NUMBER         := FND_API.G_MISS_NUM
,   percent                       NUMBER         := FND_API.G_MISS_NUM
,   quota_flag                    VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   salesrep_id                   NUMBER         := FND_API.G_MISS_NUM
,   sales_credit_id               NUMBER         := FND_API.G_MISS_NUM
,   wh_update_date                DATE           := FND_API.G_MISS_DATE
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   line_index                    NUMBER         := FND_API.G_MISS_NUM
,   orig_sys_credit_ref           VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   change_request_code	  	  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   status_flag		  	  VARCHAR2(1)    := FND_API.G_MISS_CHAR
);
G_MISS_SALES_CREDIT_REC        SALES_CREDIT_Rec_Type;
TYPE Sales_Credit_Tbl_type     IS TABLE OF Sales_Credit_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Sales_Credit_Tbl        Sales_Credit_Tbl_Type;


TYPE Lot_Serial_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   from_serial_number            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   line_id                       NUMBER         := FND_API.G_MISS_NUM
,   lot_number                    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   lot_serial_id                 NUMBER         := FND_API.G_MISS_NUM
,   quantity                      NUMBER         := FND_API.G_MISS_NUM
,   to_serial_number              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   line_index                    NUMBER         := FND_API.G_MISS_NUM
,   orig_sys_lotserial_ref        VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   change_request_code	  	  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   status_flag		  	  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   line_set_id                   NUMBER         := FND_API.G_MISS_NUM
);

TYPE Lot_Serial_Tbl_Type IS TABLE OF Lot_Serial_Rec_Type
    INDEX BY BINARY_INTEGER;

G_MISS_Lot_Serial_Tbl            Lot_Serial_Tbl_Type ;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Order
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    ASO_QUOTE_PUB.qte_line_Rec_Type  Required
--       P_Qte_Rec           IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type       Required
--       P_Payment_Tbl       IN    ASO_QUOTE_PUB.Payment_Tbl_Type   Required
--       P_Price_Adj_Tbl     IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type   Required
--       P_Qte_Line_Dtl_Rec  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type  Required
--       P_Shipment_Tbl      IN    ASO_QUOTE_PUB.Shipment_Tbl_Type    Required
--       P_Tax_Details_Tbl    IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type    Required
--       P_Quote_Line_Rltship   IN  ASO_QUOTE_PUB.Quote_Line_Rltship_Type Required
--   OUT:
--       x_order_number            OUT NOCOPY /* file.sql.39 change */  NUMBER
--       X_Order_Header_Rec        OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type
--       X_Order_Line_Tbl          OUT NOCOPY /* file.sql.39 change */  Order_Line_Tbl_type
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_order(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl   IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_header_sales_credit_TBL      IN   Sales_credit_tbl_type
			:= G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_Tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl      IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   Sales_credit_tbl_type
			:= G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   Lot_Serial_Tbl_Type
                             := G_MISS_Lot_Serial_Tbl,
    P_Control_Rec           IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_order
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    ASO_QUOTE_PUB.qte_line_Rec_Type          Required
--       P_Qte_Rec           IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type               Required
--       P_Payment_Tbl       IN    ASO_QUOTE_PUB.Payment_Tbl_Type           Required
--       P_Price_Adj_Tbl     IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type         Required
--       P_Qte_Line_Dtl_Rec  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type      Required
--       P_Shipment_Tbl      IN    ASO_QUOTE_PUB.Shipment_Tbl_Type          Required
--       P_TAX_DETAIL_Tbl      IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type    Required
--       P_Quote_Line_Rltship   IN   ASO_QUOTE_PUB. Quote_Line_Rltship_Type Required
--   OUT:
--       x_order_number            OUT NOCOPY /* file.sql.39 change */  NUMBER
--       X_Order_Header_Rec        OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type
--       X_Order_Line_Tbl          OUT NOCOPY /* file.sql.39 change */  Order_Line_Tbl_type
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
PROCEDURE Update_order(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type       := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl       IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl        IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
   P_header_sales_credit_TBL      IN   Sales_credit_tbl_type := G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl       IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl        IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
   P_Line_sales_credit_TBL      IN   Sales_credit_tbl_type := G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   Lot_Serial_Tbl_Type
                             := G_MISS_Lot_Serial_Tbl,
    P_Control_Rec                IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_order
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       p_order_number            IN  NUMBER      Required
--       P_Order_Header_Rec        IN  Order_Header_Rec_Type
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
PROCEDURE Delete_order(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Order_Header_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


-- This procedure can be used to book orders that are in an entered state.

PROCEDURE BOOK_ORDER(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_order_header_id            IN  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


-- this procedure is used to cancel an order. if successful it will set the
-- cancelled_flag to 'Y' in oe_order_headers

PROCEDURE CANCEL_ORDER(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_order_header_id            IN  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--- create order overloaded
-- the following procedure is an overloaded procedure which takes the same
-- parameters as the create order but all record types are defined in
-- ASO_QUOTE_PUB.

PROCEDURE Create_order(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl   IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_header_sales_credit_TBL   IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_Tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl      IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Line_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Control_Rec           IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



PROCEDURE Update_order(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			 := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
		        := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_header_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl        IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type  			 := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
   P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			 := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Line_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Control_Rec                IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

PROCEDURE get_acct_site_uses
(
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_site_use_id OUT NOCOPY /* file.sql.39 change */   number
);

PROCEDURE get_cust_acct_roles
(
p_party_id IN NUMBER,
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */   number
);

  PROCEDURE Get_Cust_Accnt_Id(
   P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                           := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
   p_Party_Id  IN  NUMBER,
   p_Cust_Acct_Id  OUT NOCOPY /* file.sql.39 change */   NUMBER,
   x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
   x_msg_count  OUT NOCOPY /* file.sql.39 change */   NUMBER,
   x_msg_data  OUT NOCOPY /* file.sql.39 change */   VARCHAR2);



FUNCTION Get_Header_Status (
    p_Header_Id		NUMBER) RETURN VARCHAR2;

FUNCTION Get_Line_Status (
    p_Line_Id		NUMBER) RETURN VARCHAR2;

FUNCTION Total_Order_Price (
   p_Header_Id	IN	NUMBER) RETURN NUMBER;

FUNCTION Total_List_Price (
   p_Header_Id	IN	NUMBER,
   p_Line_Id in NUMBER,
   p_line_number in NUMBER,
   p_shipment_number in number default null) RETURN NUMBER;

FUNCTION GET_ORDER_TOTAL(
   P_HEADER_ID  IN        NUMBER,
   P_LINE_ID    IN        NUMBER,
   P_TOTAL_TYPE IN        VARCHAR2   DEFAULT 'ALL')
RETURN NUMBER;

PROCEDURE Initialize_OM_rec_types
(
     px_header_rec           IN OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Rec_Type,
     px_line_tbl             IN OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Tbl_Type,
     p_line_tbl_count        IN           NUMBER
);

FUNCTION Salesrep_Id (
     employee_person_id NUMBER
     )
RETURN NUMBER;

FUNCTION Service_Index (
     quote_line_id     NUMBER := FND_API.G_MISS_NUM,
     quote_line_index  NUMBER := FND_API.G_MISS_NUM,
     P_Line_Rltship_Tbl    ASO_QUOTE_PUB.Line_Rltship_Tbl_Type ,
     p_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type
     )
RETURN NUMBER;

End ASO_ORDER_INT;

 

/
