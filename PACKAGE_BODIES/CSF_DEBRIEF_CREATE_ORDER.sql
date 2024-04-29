--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_CREATE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_CREATE_ORDER" as
/* $Header: csfpodcb.pls 115.5 2000/12/05 11:41:53 pkm ship     $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_CREATE_ORDER
-- Purpose          :
-- History          : Modified by Ildiko Balint on 04-AUG-2000
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_CREATE_ORDER';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csfpodcb.pls';

PROCEDURE CREATE_ORDER (
P_Currency_Code	        IN VARCHAR2,
P_Party_Id		IN NUMBER,
P_Inventory_Item_Id	IN NUMBER,
P_quantity 		IN NUMBER,
P_Uom_Code         	IN VARCHAR2,
P_Order_Type_Code	IN VARCHAR2,
P_Quote_Header_Id       IN NUMBER,
P_Order_Type_Id         IN NUMBER,
P_Price_List_Id	        IN NUMBER,
P_Employee_Person_Id    IN NUMBER,
P_Cust_Account_Id       IN NUMBER,
P_Shipment_Id           IN NUMBER,
X_Order_Header_Id       OUT  NUMBER,
X_Return_Status         OUT  VARCHAR2,
X_Msg_Count             OUT  NUMBER,
X_Msg_Data              OUT  VARCHAR2

) is
     l_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
     l_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
     l_hd_payment_tbl          ASO_QUOTE_PUB.Payment_Tbl_Type;
     l_payment_rec             ASO_QUOTE_PUB.Payment_Rec_Type;
     l_hd_shipment_tbl         ASO_QUOTE_PUB.Shipment_tbl_Type;
     l_hd_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
     l_tax_detail_rec          ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
     l_ln_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
     x_order_header_rec        ASO_ORDER_INT.Order_Header_rec_type;
     x_order_line_tbl          ASO_ORDER_INT.Order_Line_tbl_type;
     p_control_rec             ASO_ORDER_INT.control_rec_type;
     x_return_status_oe        VARCHAR2(1);
     x_msg_count_oe            NUMBER;
     x_msg_data_oe             VARCHAR2(2000);

BEGIN

      l_qte_header_rec.quote_source_code  := 'ASO';
      l_qte_header_rec.currency_code      := p_currency_code;
      l_qte_header_rec.party_id           := p_party_id;
      l_qte_header_rec.quote_header_id    := p_quote_header_id;
      l_qte_header_rec.order_type_id      := p_order_type_id;
      l_qte_header_rec.price_list_id      := p_price_list_id;
      l_qte_header_rec.employee_person_id := p_employee_person_id;
      l_qte_header_rec.cust_account_id    := p_cust_account_id;
      p_control_rec.book_flag             := FND_API.G_TRUE;
      l_qte_line_tbl(1).inventory_item_id := p_inventory_item_id;
      l_qte_line_tbl(1).quantity          := p_quantity;
      l_qte_line_tbl(1).UOM_code          := p_uom_code;
      l_qte_line_tbl(1).price_list_id     := p_price_list_id;
      l_qte_line_tbl(1).line_category_code:= p_order_type_code;
      l_ln_shipment_tbl(1).shipment_id    := p_shipment_id;
      l_ln_shipment_tbl(1).quantity       := p_quantity;
      l_ln_shipment_tbl(1).qte_line_index := 1;
      l_ln_shipment_tbl(1).ship_method_code:= 'UPS';

ASO_ORDER_INT.Create_order(
    P_Api_Version_Number    => 1.0,
    P_Qte_Rec               => l_qte_header_rec,
    P_Header_Payment_Tbl    => l_hd_payment_tbl,
    P_Header_Shipment_Tbl   => l_hd_shipment_tbl,
    P_Header_TAX_DETAIL_Tbl => l_hd_tax_detail_tbl,
    P_Qte_Line_Tbl          => l_qte_line_tbl,
    P_Line_Shipment_Tbl     => l_ln_shipment_tbl,
    P_control_rec           => p_control_rec,
    X_Order_Header_Rec      => x_order_header_rec,
    X_Order_Line_Tbl        => x_order_line_tbl,
    X_Return_Status         => x_return_status_oe,
    X_Msg_Count             => x_msg_count_oe,
    X_Msg_Data              => x_msg_data_oe
    );

x_order_header_id := x_order_header_rec.order_header_id;

oe_debug_pub.add('no. of OE messages :'||x_msg_count_oe,1);
for k in 1 ..x_msg_count_oe loop
        x_msg_data_oe := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
oe_debug_pub.add(substr(x_msg_data_oe,1,255));
end loop;

x_msg_data      := substr(x_msg_data_oe,1,200);
x_return_status := x_return_status_oe;
x_msg_count     := x_msg_count_oe;

end CREATE_ORDER ;
end CSF_DEBRIEF_CREATE_ORDER ;


/
