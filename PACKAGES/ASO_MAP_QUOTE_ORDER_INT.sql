--------------------------------------------------------
--  DDL for Package ASO_MAP_QUOTE_ORDER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_MAP_QUOTE_ORDER_INT" AUTHID CURRENT_USER as
/* $Header: asoimqos.pls 120.2.12010000.1 2008/07/28 22:14:30 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_MAP_QUOTE_ORDER_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


PROCEDURE Map_Quote_to_order(
    P_Operation        IN    VARCHAR2,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                       := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl  IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl  IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                       := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl  IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_header_sales_credit_TBL   IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
                        := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_TBL IN    ASO_QUOTE_PUB.Qte_Line_Dtl_TBL_Type
                       := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                       := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
                        := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Calculate_Price_Flag  IN   VARCHAR2 := FND_API.G_FALSE
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Payment_Tbl_Type
);


PROCEDURE get_org_contact(
  p_party_id IN NUMBER,
  x_org_contact OUT NOCOPY /* file.sql.39 change */  number
);

PROCEDURE get_acct_site_uses
(
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_site_use_id OUT NOCOPY /* file.sql.39 change */  number
);

PROCEDURE get_cust_acct_roles
(
p_party_id IN NUMBER,
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_party_id   OUT NOCOPY /* file.sql.39 change */  NUMBER,
x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */  number
);

  PROCEDURE Get_Cust_Accnt_Id(
   P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                           := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
   p_Party_Id  IN  NUMBER,
   p_Cust_Acct_Id  OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count  OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data  OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE get_org_contact_role(
p_Org_Contact_Id      IN  NUMBER
 ,p_Cust_account_id     IN  NUMBER
 ,x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,x_party_id         OUT NOCOPY /* file.sql.39 change */  NUMBER
 ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */  NUMBER
);


PROCEDURE map_header_price_attr(
        p_header_price_attributes_tbl IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        p_qte_rec  IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_operation IN VARCHAR2,
        x_Header_price_Att_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Price_Att_Tbl_Type
 );

PROCEDURE  map_header_price_adj(
        p_header_price_adj_tbl  IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        p_qte_rec  IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_operation IN VARCHAR2 ,
        x_Header_Adj_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Tbl_Type
 );

PROCEDURE    map_header_price_adj_attr(
         p_header_price_adj_attr_tbl  IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
         p_operation IN VARCHAR2,
         x_header_adj_att_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Att_Tbl_Type
     );

PROCEDURE  map_header_price_adj_rltn(
        P_Header_Price_Adj_rltship_Tbl  IN  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        P_operation IN VARCHAR2,
        x_Header_Adj_Assoc_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
     );

PROCEDURE  map_header_sales_credits(
     P_header_sales_credit_Tbl  IN  ASO_QUOTE_PUB.Sales_credit_tbl_type  ,
     p_operation  IN VARCHAR2,
     p_qte_rec  IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_header_operation IN VARCHAR2,
     x_Header_Scredit_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Scredit_Tbl_Type
     );

PROCEDURE map_line_price_att(
        p_line_price_attributes_tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_operation IN   VARCHAR2,
        x_line_price_att_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
        );

PROCEDURE map_line_price_adj(
        p_line_price_adj_tbl  IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        p_line_price_adj_attr_tbl  IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_operation IN VARCHAR2,
        x_line_adj_tbl  IN OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Tbl_Type,
        x_line_adj_att_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type,
	   lx_Line_Price_Adj_rltship_Tbl IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
        );


PROCEDURE map_line_price_adj_rltn(
        P_Line_Price_Adj_rltship_Tbl  IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
	   p_operation  IN VARCHAR2,
        x_Line_Adj_Assoc_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
        );

PROCEDURE map_line_sales_credit(
        P_line_sales_credit_Tbl  IN   ASO_QUOTE_PUB.Sales_credit_tbl_type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_line_operation IN VARCHAR2,
        p_operation  IN  VARCHAR2,
        x_Line_Scredit_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
        );

PROCEDURE map_lot_serial(
        P_lot_serial_tbl  IN  ASO_QUOTE_PUB.Lot_Serial_Tbl_Type,
        p_operation IN VARCHAR2,
        p_line_index IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        x_lot_serial_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Tbl_Type
        );


-- Line Payments Change
PROCEDURE map_line_payments(
        P_line_payment_Tbl  IN   ASO_QUOTE_PUB.payment_tbl_type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_line_operation IN VARCHAR2,
        p_operation  IN  VARCHAR2,
        x_Line_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type,
        x_Line_Payment_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
        );


End ASO_MAP_QUOTE_ORDER_INT;

/
