--------------------------------------------------------
--  DDL for Package IBE_QUOTE_SAVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_SAVE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVQCUS.pls 120.7.12010000.3 2016/04/04 09:07:02 kdosapat ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_Save_pvt
-- Purpose          :
-- NOTE             :

-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  CONSTANT NUMBER := 30;

-- line codes to distinguish line level operations
STANDARD_LINE_CODE       CONSTANT NUMBER := 0;
SERVICEABLE_LINE_CODE    CONSTANT NUMBER := 1;
SERVICE_LINE_CODE        CONSTANT NUMBER := 2;
MODEL_UI_LINE_CODE       CONSTANT NUMBER := 3;
MODEL_BUNDLE_LINE_CODE   CONSTANT NUMBER := 4;


-- save types to give context to the overall operation
-- used for api routing and validations
SAVE_NORMAL              CONSTANT NUMBER := 0;
SAVE_ADDTOCART           CONSTANT NUMBER := 1;
SAVE_EXPRESSORDER        CONSTANT NUMBER := 2;
SALES_ASSISTANCE         CONSTANT NUMBER := 5;
UPDATE_EXPRESSORDER      CONSTANT NUMBER := 7;
OP_DELETE_CART           CONSTANT NUMBER := 8;
OP_DUPLICATE_CART           CONSTANT NUMBER := 9;


PROCEDURE Delete(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                ,
   x_msg_count          OUT NOCOPY NUMBER                  ,
   x_msg_data           OUT NOCOPY VARCHAR2                ,
   p_quote_header_id    IN  NUMBER                         ,
   p_expunge_flag       IN  VARCHAR2 :=FND_API.G_TRUE      ,
   p_minisite_id        IN  NUMBER   :=FND_API.G_MISS_NUM  ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_Quote_access_tbl   IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE
                            := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl ,
   p_notes              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   -- in even that we are deleting a shared cart
   -- could be owner or admin recipient
   p_initiator_party_id IN  NUMBER  :=FND_API.G_MISS_NUM  ,
   p_initiator_account_id IN NUMBER  :=FND_API.G_MISS_NUM
);


PROCEDURE DeleteAllLines(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                ,
   x_msg_count          OUT NOCOPY NUMBER                  ,
   x_msg_data           OUT NOCOPY VARCHAR2                ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_sharee_number      IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE
);


procedure Get_quote_expiration_date(
   p_api_version      IN  NUMBER   := 1.0                       ,
   p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE            ,
   p_commit           IN  VARCHAR2 := FND_API.G_FALSE           ,
   x_return_status    OUT NOCOPY  VARCHAR2                      ,
   x_msg_count        OUT NOCOPY  NUMBER                        ,
   x_msg_data         OUT NOCOPY  VARCHAR2                      ,
   p_quote_header_rec IN aso_quote_pub.qte_header_rec_type      ,
   X_expiration_date OUT NOCOPY  DATE);

PROCEDURE request_for_sales_assistance (
   P_Api_Version        IN NUMBER                     ,
   p_Init_Msg_List      IN VARCHAR2:= FND_API.G_FALSE ,
   p_Commit             IN VARCHAR2:= FND_API.G_FALSE ,
   x_return_status      OUT NOCOPY  VARCHAR2          ,
   x_msg_count          OUT NOCOPY  NUMBER            ,
   x_msg_data           OUT NOCOPY  VARCHAR2          ,
   x_last_update_date   OUT NOCOPY  Date              ,
   p_minisite_id        IN NUMBER                     ,
   p_last_update_date   IN Date                       ,
   p_quote_header_id    IN  NUMBER:= FND_API.G_MISS_NUM,
   p_party_id           IN  NUMBER:= FND_API.G_MISS_NUM,
   p_cust_account_id    IN  NUMBER:= FND_API.G_MISS_NUM,
   p_validate_user      IN  VARCHAR2:= FND_API.G_FALSE ,
   P_quote_name         IN varchar2                   ,
   P_Reason_code        IN varchar2                   ,
   p_url                IN varchar2 := FND_API.G_MISS_CHAR,
   P_COMMENTS           IN varchar2,
   p_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_contract_context   IN  VARCHAR2 :='N',
   p_notes              IN  VARCHAR2 := NULL)  ;


-- API NAME:  SAVE
-- IN PARAMETERS (non-standard)
-- OUT PARAMETERS (non-standard)
--   x_new_quote_Header_id
PROCEDURE SAVE(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_auto_update_active_quote IN   VARCHAR2   := FND_API.G_TRUE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR

  ,p_sharee_Number            in   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          in   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   in   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE


  ,p_Control_Rec              IN   ASO_QUOTE_PUB.Control_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Control_Rec
  ,p_Qte_Header_Rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
                                     := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_QUOTE_PUB.Shipment_tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
                                     := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
                                     := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl
  ,p_save_type                IN   NUMBER := FND_API.G_MISS_NUM
  ,x_quote_header_id          OUT NOCOPY varchar2
  ,x_last_update_date         OUT NOCOPY DATE
  ,X_Return_Status            OUT NOCOPY VARCHAR2
  ,X_Msg_Count                OUT NOCOPY NUMBER
  ,X_Msg_Data                 OUT NOCOPY VARCHAR2
);

PROCEDURE Save(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_auto_update_active_quote IN   VARCHAR2   := FND_API.G_TRUE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR

  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE

  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_save_type                IN   NUMBER := FND_API.G_MISS_NUM
  ,x_quote_header_id          OUT NOCOPY varchar2
  ,x_last_update_date         OUT NOCOPY DATE

  ,x_Qte_Header_Rec           IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
  ,x_Hd_Price_Attributes_Tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Hd_Payment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
  ,x_Hd_Shipment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type
  ,x_Hd_Shipment_Rec          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Rec_Type
  ,x_Hd_Freight_Charge_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_Hd_Tax_Detail_Tbl        IN OUT NOCOPY ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
  ,x_Qte_Line_Tbl             IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_Qte_Line_Dtl_Tbl         IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
  ,x_Line_Attr_Ext_Tbl        IN OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
  ,x_Line_rltship_tbl         IN OUT NOCOPY ASO_Quote_Pub.Line_Rltship_Tbl_Type
  ,x_Ln_Price_Attributes_Tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Ln_Payment_Tbl           IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
  ,x_Ln_Shipment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type
  ,x_Ln_Freight_Charge_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_Ln_Tax_Detail_Tbl        IN OUT NOCOPY ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
  ,x_Price_Adjustment_Tbl     IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Attr_Tbl       IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type

  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE UpdateQuoteForSharee(
  p_api_version_number           IN   NUMBER
  ,p_init_msg_list               IN   VARCHAR2   := FND_API.G_FALSE
  ,p_commit                      IN   VARCHAR2    := FND_API.G_FALSE

  ,p_sharee_Party_Id         IN NUMBER
  ,p_sharee_Cust_account_Id      IN NUMBER
  ,p_changeowner                 IN   VARCHAR2   := FND_API.G_FALSE

  ,P_Control_Rec         in   ASO_QUOTE_PUB.Control_Rec_Type

  ,P_Qte_Header_Rec             IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
                                 := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec
  ,p_Hd_Price_Attributes_Tbl        in   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Price_Attributes_Tbl
  ,p_Hd_Payment_Tbl                 in   ASO_QUOTE_PUB.Payment_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
  ,p_Hd_Shipment_Tbl                in   ASO_QUOTE_PUB.Shipment_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_SHIPMENT_Tbl
  ,p_Hd_Tax_Detail_Tbl              in   ASO_QUOTE_PUB.TAX_DETAIL_TBL_TYPE
                                    := ASO_QUOTE_PUB.G_MISS_Tax_Detail_Tbl
  ,p_Hd_Freight_Charge_Tbl          in   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Freight_Charge_Tbl

  ,p_qte_line_tbl                   in  ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                    := aso_quote_pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl               in   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_rltship_tbl               in   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl
  ,p_Line_Attr_Ext_Tbl              in   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_Tbl
  ,p_Ln_Price_Attributes_Tbl        in   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl                 in   ASO_QUOTE_PUB.Payment_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl                in   ASO_QUOTE_PUB.Shipment_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL
  ,p_Ln_Tax_Detail_Tbl              in   ASO_QUOTE_PUB.TAX_DETAIL_TBL_TYPE
                                    := ASO_QUOTE_PUB.G_MISS_Tax_Detail_Tbl
  ,p_Ln_Freight_Charge_Tbl          in   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Freight_Charge_Tbl
  ,p_Price_Adj_Attr_Tbl             in   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adjustment_Tbl           in   ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Price_Adj_Tbl
  ,p_Price_Adj_Rltship_Tbl          in   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_Tbl

  ,x_qte_header_rec                 OUT NOCOPY  ASO_QUOTE_PUB.Qte_Header_Rec_Type
  ,x_qte_line_tbl                   OUT NOCOPY  ASO_QUOTE_PUB.Qte_Line_Tbl_Type
  ,X_Return_Status                  OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                      OUT NOCOPY  NUMBER
  ,X_Msg_Data                       OUT NOCOPY  VARCHAR2
);
-- formerly AddItemsToCart; the original addItemsToCart
-- this is the one that handles adding of std, services, cartlevel services
PROCEDURE AddItemsToCart_orig(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_ql_line_codes            IN   jtf_number_table       := NULL
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec

  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,P_save_flag                IN   NUMBER := SAVE_ADDTOCART
  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_Qte_Line_Tbl          OUT NOCOPY  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
);
-- formerly AddModelsToCart
-- same signature, but expanded to match the original addItemsToCart
-- this should be the main entry point for all item types as it internally calls addItemsToCart_orig
PROCEDURE AddItemsToCart(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Bundle_Flag              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_ql_line_codes            IN   jtf_number_table       := NULL
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,P_save_flag                IN   NUMBER := SAVE_ADDTOCART
  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_Qte_Line_Tbl          OUT NOCOPY  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE getHdrDefaultValues(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE

  ,p_minisite_id              IN   NUMBER

  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl

  ,x_Qte_Header_Rec           OUT NOCOPY   ASO_Quote_Pub.Qte_Header_Rec_Type
  ,x_hd_Price_Attributes_Tbl  OUT NOCOPY   ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_hd_Payment_Tbl           OUT NOCOPY   ASO_Quote_Pub.Payment_Tbl_Type
  ,x_hd_Shipment_TBL          OUT NOCOPY   ASO_Quote_Pub.Shipment_tbl_Type
  ,x_hd_Freight_Charge_Tbl    OUT NOCOPY   ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_hd_Tax_Detail_Tbl        OUT NOCOPY   ASO_Quote_Pub.Tax_Detail_Tbl_Type
  ,x_Price_Adjustment_Tbl     OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Attr_Tbl       OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl    OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type

  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
);

PROCEDURE getHdrDefaultAddress(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Shipment_TBL   IN OUT NOCOPY ASO_Quote_Pub.Shipment_tbl_Type
                              ,px_qte_header_rec    IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_party_site_use     IN varchar2
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              );

PROCEDURE getHdrDefaultShipMethod(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Shipment_TBL   IN OUT NOCOPY ASO_Quote_Pub.Shipment_tbl_Type
                              ,p_qte_header_rec     IN     ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_minisite_id        IN     Number
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              );

PROCEDURE getHdrDefaultPaymentMethod(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Payment_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
                              ,p_qte_header_rec     IN     ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_minisite_id        IN     Number
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              );

PROCEDURE getHdrDefaultTaxExemption(
                               P_Api_Version_Number IN  NUMBER
                              ,p_Init_Msg_List      IN  VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN  VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Tax_Detail_Tbl IN  OUT NOCOPY ASO_Quote_Pub.Tax_Detail_Tbl_Type
                              ,p_qte_header_rec     IN  ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              );

PROCEDURE getHdrDefaultEndCustomer(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_hd_Shipment_TBL    IN     ASO_Quote_Pub.Shipment_tbl_Type
                              ,px_qte_header_rec    IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              );

 PROCEDURE Create_Contract_For_Quote(
              P_Api_Version_Number     IN  NUMBER   := OKC_API.G_MISS_NUM
             ,p_Init_Msg_List          IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_quote_id               IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
             ,p_rel_type               IN  OKC_K_REL_OBJS.RTY_CODE%TYPE := OKC_API.G_MISS_CHAR
             ,p_terms_agreed_flag      IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_trace_mode             IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_party_id               IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_cust_account_id        IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_quote_retrieval_number IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_minisite_id            IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_validate_user          IN  VARCHAR2 := FND_API.G_FALSE
                ,p_url                    IN  VARCHAR2 := FND_API.G_MISS_CHAR
             ,x_contract_id           OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
             ,x_contract_number       OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
             ,x_return_status          OUT NOCOPY VARCHAR2
             ,x_msg_count              OUT NOCOPY NUMBER
             ,x_msg_data               OUT NOCOPY VARCHAR2
             );

 --Added for 11.5.11, Duplicate Cart feature - MaithiliK
 PROCEDURE DUPLICATE_CART (
          P_Api_Version           IN  NUMBER                     ,
          p_Init_Msg_List      IN  VARCHAR2:= FND_API.G_FALSE ,
          p_Commit             IN  VARCHAR2:= FND_API.G_FALSE ,
          x_return_status      OUT NOCOPY VARCHAR2            ,
          x_msg_count          OUT NOCOPY NUMBER              ,
          x_msg_data           OUT NOCOPY VARCHAR2            ,
          x_last_update_date   OUT NOCOPY Date                ,
          x_quote_header_id    OUT NOCOPY NUMBER              ,
          p_last_update_date   IN  Date                       ,
          p_quote_header_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_party_id           IN  NUMBER:= FND_API.G_MISS_NUM,
          p_cust_account_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_validate_user      IN  VARCHAR2:= FND_API.G_FALSE ,
          P_new_quote_name     IN  VARCHAR2                   ,
          p_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
          p_minisite_id        IN  NUMBER);

TYPE ConfigCurTyp IS REF CURSOR;
-- API NAME:  RECONFIGURE_FROM_IB
PROCEDURE RECONFIGURE_FROM_IB(
   p_api_version_number      IN  NUMBER   := 1
  ,p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE
  ,p_commit                  IN  VARCHAR2 := FND_API.G_FALSE
  ,p_Control_Rec             IN   ASO_QUOTE_PUB.Control_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Control_Rec
  ,p_Qte_Header_Rec          IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
                                     := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec
  ,p_instance_ids             IN   jtf_number_table       := NULL
  ,x_config_line              OUT NOCOPY ConfigCurTyp
  ,x_last_update_date         OUT NOCOPY DATE
  ,x_return_status            OUT NOCOPY VARCHAR2
  ,x_msg_count                OUT NOCOPY NUMBER
  ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_SUPPORT_AND_QUANTITY(
	p_api_version        		IN  NUMBER,
    p_init_msg_list      		IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      		OUT NOCOPY VARCHAR2,
    x_msg_count          		OUT NOCOPY NUMBER,
    x_msg_data           		OUT NOCOPY VARCHAR2,

    p_quote_header_id			IN	NUMBER,
    p_quote_line_id_tbl			IN	JTF_NUMBER_TABLE := NULL,
    p_line_quantity_tbl			IN 	JTF_NUMBER_TABLE := NULL,
    p_new_service_id_tbl		IN 	JTF_NUMBER_TABLE := NULL,
   	p_organization_id           IN  NUMBER   := FND_API.G_MISS_NUM,

    p_party_id                  IN  NUMBER   := FND_API.G_MISS_NUM,
    p_cust_account_id           IN  NUMBER   := FND_API.G_MISS_NUM,
    p_sharee_number             IN  NUMBER   := FND_API.G_MISS_NUM,

   	p_minisite_id               IN  NUMBER   := FND_API.G_MISS_NUM,
   	p_price_list_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   	p_currency_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	p_header_pricing_event      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   	p_save_type                 IN  NUMBER   := FND_API.G_MISS_NUM,
    p_last_update_date			IN 	DATE	:= FND_API.G_MISS_DATE,
    x_last_update_date			IN OUT	NOCOPY DATE
);


END IBE_Quote_Save_pvt;

/
