--------------------------------------------------------
--  DDL for Package Body AST_EVENT_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_EVENT_ORDER_PKG" AS
 /* $Header: astevoeb.pls 115.7 2002/02/06 12:32:47 pkm ship     $ */

    g_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    g_qte_line_tbl        ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    g_hd_payment_tbl      ASO_QUOTE_PUB.Payment_Tbl_Type;
    g_payment_rec         ASO_QUOTE_PUB.Payment_Rec_Type;
    g_hd_shipment_tbl     ASO_QUOTE_PUB.Shipment_tbl_Type;
    g_hd_tax_detail_tbl   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    g_tax_detail_rec      ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    g_ln_shipment_tbl     ASO_QUOTE_PUB.Shipment_Tbl_Type;
 -- ***************************************************
 PROCEDURE open_order (
     p_cust_party_id           IN NUMBER
   , p_cust_account_id         IN NUMBER
   , p_currency_code           IN VARCHAR2
   , p_source_code             IN VARCHAR2 DEFAULT 'ASO'
   , p_order_type_id           IN NUMBER DEFAULT 1000
   , p_price_list_id           IN NUMBER
   , p_employee_id             IN NUMBER
   , p_invoice_party_id        IN NUMBER
   , p_invoice_party_site_id   IN NUMBER
   , p_quote_header_id         IN NUMBER DEFAULT NULL
 ) IS
 BEGIN

    -- reinitialize the order header record types
    g_qte_header_rec  := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC;
    g_payment_rec     := ASO_QUOTE_PUB.G_MISS_Payment_REC;
    -- assign parameters passed to the quote header record
    g_qte_header_rec.quote_source_code  := p_source_code ;
    g_qte_header_rec.currency_code := p_currency_code    ;
    g_qte_header_rec.party_id := p_cust_party_id;
    -- worked without Quote header id, why would have a quote header with
    -- an event order anyway
    IF ( p_quote_header_id IS NOT NULL ) THEN
       g_qte_header_rec.quote_header_id := p_quote_header_id;
    END IF;
    g_qte_header_rec.order_type_id := p_order_type_id;
    g_qte_header_rec.price_list_id :=  p_price_list_id;
 -- employee id was set up to jtf_rs_salesreps table
 -- the create_order check on ra_salesreps view which does not included the jtf
 -- but return 'S'uccess
    g_qte_header_rec.employee_person_id := p_employee_id;
    g_qte_header_rec.cust_account_id := p_cust_account_id;
    g_qte_header_rec.invoice_to_party_id := p_invoice_party_id;
    g_qte_header_rec.invoice_to_party_site_id  := p_invoice_party_site_id;
    -- reinitialize the order line table types
    g_hd_shipment_tbl := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;
    g_qte_line_tbl    := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
    g_ln_shipment_tbl := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;
    g_hd_payment_tbl  := ASO_QUOTE_PUB.G_MISS_Payment_TBL;

 END open_order;
 -- ***************************************************
 PROCEDURE add_order_line (
     p_ship_party_id      IN NUMBER
   , p_ship_party_site_id IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_line_list_price    IN NUMBER
   , p_quantity           IN NUMBER DEFAULT 1
   , p_discount           IN NUMBER DEFAULT NULL
   , p_discount_uom       IN VARCHAR2 DEFAULT NULL
   , p_uom_code           IN VARCHAR2 DEFAULT 'Ea'
   , p_price_list_id      IN NUMBER DEFAULT NULL
   , p_price_list_line_id IN NUMBER DEFAULT NULL
 ) IS
  l_line_num NUMBER ;
 BEGIN
   l_line_num := g_hd_shipment_tbl.COUNT + 1;
   -- if the account is null; create_order ship to org.
   -- complaint on ship_to_contact if passed individual party_id
   if g_qte_header_rec.cust_account_id is not null then
     g_hd_shipment_tbl(l_line_num).ship_to_party_id := p_ship_party_id;
   else
     g_hd_shipment_tbl(l_line_num).ship_to_party_id := g_qte_header_rec.party_id;
   end if;
   g_hd_shipment_tbl(l_line_num).ship_to_party_site_id := p_ship_party_site_id;
   g_qte_line_tbl(l_line_num).inventory_item_id := p_inventory_item_id;
   g_qte_line_tbl(l_line_num).quantity := p_quantity;
   IF p_discount_uom = 'P'  THEN -- percentage
	g_qte_line_tbl(l_line_num).line_adjusted_percent := p_discount;
   ELSIF p_discount_uom = 'A' THEN -- amount
     g_qte_line_tbl(l_line_num).line_adjusted_amount := p_discount;
   ELSE
     NULL;
   END IF;
   g_qte_line_tbl(l_line_num).UOM_code := p_uom_code;
   IF ( p_price_list_id IS NULL ) THEN
      g_qte_line_tbl(l_line_num).price_list_id := g_qte_header_rec.price_list_id;
   ELSE
      g_qte_line_tbl(l_line_num).price_list_id := p_price_list_id;
   END IF;
   g_qte_line_tbl(l_line_num).line_category_code := 'ORDER';
   g_ln_shipment_tbl(l_line_num).quantity := p_quantity;
   g_ln_shipment_tbl(l_line_num).qte_line_index := l_line_num;
 END add_order_line;
 -- ***************************************************
 PROCEDURE submit_order (
     p_payment_term_id          IN NUMBER DEFAULT NULL
   , p_payment_amount           IN NUMBER DEFAULT NULL
   , p_payment_type             IN VARCHAR2 DEFAULT NULL
   , p_payment_option           IN VARCHAR2 DEFAULT NULL
   , p_credit_card_code         IN VARCHAR2 DEFAULT NULL
   , p_credit_card_holder_name  IN VARCHAR2 DEFAULT NULL
   , p_payment_ref_number       IN VARCHAR2 DEFAULT NULL
   , p_credit_card_approval     IN VARCHAR2 DEFAULT NULL
   , p_credit_card_expiration   IN DATE DEFAULT NULL
   , p_total_discount           IN NUMBER DEFAULT NULL
   , p_total_discount_uom       IN VARCHAR2 DEFAULT NULL
   , x_return_status            OUT VARCHAR2
   , x_order_header_rec         OUT ASO_ORDER_INT.Order_Header_rec_type
   , x_order_line_tbl           OUT ASO_ORDER_INT.Order_Line_tbl_type
 ) IS
    l_control_rec      ASO_ORDER_INT.control_rec_type;
    l_api_ver          NUMBER := 1.0;
    l_init_msg_list    VARCHAR2(1) := FND_API.G_TRUE;
    l_commit           VARCHAR2(1) := FND_API.G_TRUE;
    x_msg_count        NUMBER;
    x_msg_data         VARCHAR2(2000);
 BEGIN
    l_control_rec.book_flag := FND_API.G_TRUE;
    l_control_rec.calculate_price := FND_API.G_TRUE;

    -- assign payment information passed
    IF ( p_payment_term_id IS NOT NULL ) THEN
       g_hd_payment_tbl(1).payment_term_id := p_payment_term_id ; -- FK RA_TERMS_B
       g_hd_payment_tbl(1).payment_type_code := p_payment_type;
       g_hd_payment_tbl(1).payment_amount := p_payment_amount ;
       IF ( p_credit_card_code IS NOT NULL ) THEN
         g_hd_payment_tbl(1).credit_card_code := p_credit_card_code;
         g_hd_payment_tbl(1).credit_card_holder_name := p_credit_card_holder_name;
         g_hd_payment_tbl(1).credit_card_expiration_date := p_credit_card_expiration;
         IF ( p_credit_card_approval IS NOT NULL ) THEN
           g_hd_payment_tbl(1).credit_card_approval_code := p_credit_card_approval;
         END IF;
       END IF;
       -- this has credit card number , PO number or check number
       g_hd_payment_tbl(1).payment_ref_number := p_payment_ref_number;
    END IF;

    IF p_total_discount_uom = 'A' THEN
      g_qte_header_rec.total_adjusted_amount  := p_total_discount ;
    ELSIF p_total_discount_uom = 'P' THEN
      g_qte_header_rec.total_adjusted_percent := p_total_discount ;
    END IF;

    -- initialize the message stack
    FND_MSG_PUB.Initialize;

    ASO_ORDER_INT.create_order(
         p_api_version_number    => l_api_ver
       , p_init_msg_list         => l_init_msg_list
       , p_commit                => l_commit
       , p_qte_rec               => g_qte_header_rec
       , p_header_payment_tbl    => g_hd_payment_tbl
       , p_header_shipment_tbl   => g_hd_shipment_tbl
       , p_header_tax_detail_tbl => g_hd_tax_detail_tbl
       , p_qte_line_tbl          => g_qte_line_tbl
       , p_line_shipment_tbl     => g_ln_shipment_tbl
       , p_control_rec           => l_control_rec
       , x_order_header_rec      => x_order_header_rec
       , x_order_line_tbl        => x_order_line_tbl
       , x_return_status         => x_return_status
       , x_msg_count             => x_msg_count
       , x_msg_data              => x_msg_data
    );

 END submit_order;
 -- ***************************************************
END ast_event_order_pkg;

/
