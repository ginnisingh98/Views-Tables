--------------------------------------------------------
--  DDL for Package Body AST_COLLTRL_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_COLLTRL_ORDER_PKG" AS
 /* $Header: astclrqb.pls 115.22 2002/12/05 20:00:50 rramacha ship $ */


    g_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    g_qte_line_tbl        ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    g_hd_shipment_tbl     ASO_QUOTE_PUB.Shipment_tbl_Type;
    g_ln_shipment_tbl     ASO_QUOTE_PUB.Shipment_Tbl_Type;

 PROCEDURE open_order (
     p_cust_party_id           IN NUMBER
   , p_cust_account_id         IN NUMBER
   , p_sold_to_contact_id	 IN NUMBER
   , p_inv_party_id            IN NUMBER
   , p_inv_party_site_id       IN NUMBER
   , p_ship_party_site_id      IN NUMBER
   , p_source_code             IN VARCHAR2
   , p_order_type_id           IN NUMBER
   , p_employee_id             IN NUMBER
   , p_campaign_id             IN NUMBER
   , p_quote_header_id         IN NUMBER
 ) IS
 BEGIN
    -- reinitialize the order header record types
    g_qte_header_rec  := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC;
    g_hd_shipment_tbl := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;

    -- assign parameters passed to the quote header record
    g_qte_header_rec.quote_source_code  := p_source_code ;
    g_qte_header_rec.party_id := p_cust_party_id;
    g_qte_header_rec.cust_account_id := p_cust_account_id;

    -- Begin Mod. Raam on 09.15.2001
    IF p_sold_to_contact_id IS NOT NULL THEN
      g_qte_header_rec.org_contact_id := p_sold_to_contact_id;
    END IF;
    -- End Mod.

    g_qte_header_rec.invoice_to_party_id := p_inv_party_id;
    g_qte_header_rec.invoice_to_party_site_id := p_inv_party_site_id;
    g_qte_header_rec.order_type_id := p_order_type_id;
    g_qte_header_rec.marketing_source_code_id := p_campaign_id;
    g_qte_header_rec.employee_person_id := p_employee_id;

    g_hd_shipment_tbl(1).ship_to_party_site_id := p_ship_party_site_id;

    -- reinitialize the order line table types
    g_qte_line_tbl    := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
    g_ln_shipment_tbl := ASO_QUOTE_PUB.G_MISS_Shipment_TBL;
 END open_order;

 PROCEDURE add_order_line (
     p_ship_party_id      IN NUMBER
   , p_ship_party_site_id IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_quantity           IN NUMBER
   , p_ship_method_code	 IN VARCHAR2
   , p_uom_code           IN VARCHAR2
   , p_line_category_code IN VARCHAR2
 ) IS
  l_order_line_ndx NUMBER;
  l_ship_line_ndx NUMBER;
 BEGIN
   l_order_line_ndx := g_qte_line_tbl.COUNT + 1;
   l_ship_line_ndx := g_ln_shipment_tbl.COUNT + 1;

   IF l_order_line_ndx = 1 THEN
     g_qte_line_tbl(l_order_line_ndx).inventory_item_id := p_inventory_item_id;
     g_qte_line_tbl(l_order_line_ndx).UOM_code := p_uom_code;
     g_qte_line_tbl(l_order_line_ndx).line_category_code := p_line_category_code;
   END IF;

   g_ln_shipment_tbl(l_ship_line_ndx).qte_line_index := 1;
   g_ln_shipment_tbl(l_ship_line_ndx).quantity := p_quantity;
   g_ln_shipment_tbl(l_ship_line_ndx).ship_to_party_id := p_ship_party_id;
   g_ln_shipment_tbl(l_ship_line_ndx).ship_to_party_site_id := p_ship_party_site_id;
   g_ln_shipment_tbl(l_ship_line_ndx).ship_method_code := p_ship_method_code;
 END add_order_line;

 PROCEDURE submit_order (
     x_return_status            OUT NOCOPY VARCHAR2
   , x_order_header_rec         OUT NOCOPY ASO_ORDER_INT.Order_Header_rec_type
   , x_order_line_tbl           OUT NOCOPY ASO_ORDER_INT.Order_Line_tbl_type
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

    -- initialize the message stack
    FND_MSG_PUB.Initialize;

    ASO_ORDER_INT.create_order(
         p_api_version_number    => l_api_ver
       , p_init_msg_list         => l_init_msg_list
       , p_commit                => l_commit
       , p_qte_rec               => g_qte_header_rec
       , p_qte_line_tbl          => g_qte_line_tbl
       , p_header_shipment_tbl   => g_hd_shipment_tbl

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
 PROCEDURE start_request(l_request_id    OUT NOCOPY NUMBER,
				     l_return_status OUT NOCOPY VARCHAR2,
				     l_msg_count     OUT NOCOPY NUMBER,
				     l_msg_data	 OUT NOCOPY VARCHAR2) IS
   l_api_version	NUMBER := 1.0;
 BEGIN
   -- Start the fulfillment request. The output request_id must be passed
   -- to all subsequent calls made for this request.
   JTF_FM_REQUEST_GRP.STart_Request
   (
    p_api_version   => l_api_version,
    x_return_status => l_return_status,
    x_msg_count     => l_msg_count,
    x_msg_data      => l_msg_data,
    x_request_id    => l_request_id
    );
 END start_request;
 -- ***************************************************
 PROCEDURE xml_request(l_content_id    IN  NUMBER,
		             l_request_type  IN  VARCHAR2,
		             l_user_note	    IN  VARCHAR2,
		             l_email	    IN  VARCHAR2,
		             l_party_id	    IN  NUMBER,
		             l_return_status OUT NOCOPY VARCHAR2,
		             l_content_xml   OUT NOCOPY VARCHAR2,
		             l_msg_count     OUT NOCOPY NUMBER,
		             l_msg_data      OUT NOCOPY VARCHAR2,
		             l_request_id    IN  NUMBER) IS
 BEGIN
   xml_request(p_content_id    => l_content_id,
		     p_request_type	 => l_request_type,
		     p_media_type	 => 'EMAIL',
		     p_user_note	 => l_user_note,
		     p_email		 => l_email,
               p_fax		 => NULL,
               p_printer	      => NULL,
		     p_party_id 	 => l_party_id,
		     x_return_status => l_return_status,
		     x_content_xml	 => l_content_xml,
		     x_msg_count	 => l_msg_count,
		     x_msg_data	 => l_msg_data,
		     p_request_id	 => l_request_id);
 END xml_request;

 PROCEDURE xml_request(p_content_id IN  NUMBER,
		       p_request_type     IN  VARCHAR2,
		       p_media_type       IN  VARCHAR2,
		       p_user_note        IN  VARCHAR2,
		       p_email            IN  VARCHAR2,
                 p_fax              IN  VARCHAR2,
                 p_printer          IN  VARCHAR2,
		       p_party_id         IN  NUMBER,
		       x_return_status    OUT NOCOPY VARCHAR2,
		       x_content_xml      OUT NOCOPY VARCHAR2,
		       x_msg_count        OUT NOCOPY NUMBER,
		       x_msg_data         OUT NOCOPY VARCHAR2,
		       p_request_id       IN  NUMBER) IS

  l_api_version	NUMBER := 1.0;
  --
  l_content_nm		VARCHAR2(100);
  l_document_type	VARCHAR2(150);
  l_bind_var		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
  l_bind_val		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
  l_bind_var_type	JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
 BEGIN
   -- Initialize the parameters for Master Document.
   --NewChange
   IF p_party_id IS NOT NULL THEN
     l_bind_var(1)      := 'id';
     l_bind_var_type(1) := 'NUMBER';
     l_bind_val(1)      := p_party_id;
   END IF;
   --l_document_type    := 'zip';

   -- This call gets the XML string for the content(Master Document) with
   -- the parameters as defined above
   JTF_FM_REQUEST_GRP.Get_Content_XML
   (
    p_api_version 	=> l_api_version,
    p_content_id	=> p_content_id,
    p_content_nm	=> l_content_nm,
    --p_document_type => l_document_type,
    p_media_type	=> p_media_type,
    p_printer		=> p_printer,
    p_email		=> p_email,
    --p_file_path     => l_file_path,
    p_fax           => p_fax,
    p_user_note	=> p_user_note,
    p_content_type	=> p_request_type,
    p_bind_var		=> l_bind_var,
    p_bind_val		=> l_bind_val,
    p_bind_var_type	=> l_bind_var_type,
    p_request_id	=> p_request_id,
    x_content_xml	=> x_content_xml,
    x_return_status => x_return_status,
    x_msg_count	=> x_msg_count,
    x_msg_data		=> x_msg_data
   );
 END xml_request;
 -- ***************************************************
 PROCEDURE submit_request(l_commit 	    IN  VARCHAR2,
					 l_return_status   OUT NOCOPY VARCHAR2,
					 l_msg_count	    OUT NOCOPY NUMBER,
					 l_msg_data	    OUT NOCOPY VARCHAR2,
					 l_subject	    IN  VARCHAR2,
					 l_source_code_id  IN  NUMBER,
					 l_party_id	    IN  NUMBER,
					 l_user_id	    IN  NUMBER,
					 l_extended_header IN  VARCHAR2,
					 l_content_xml	    IN  VARCHAR2,
					 l_request_id	    IN  NUMBER) IS
   l_api_version	NUMBER := 1.0;
 BEGIN

   -- Submit the fulfillment request
   JTF_FM_REQUEST_GRP.Submit_Request
   ( p_api_version     => l_api_version,
     p_commit		   => l_commit,
     x_return_status   => l_return_status,
     x_msg_count	   => l_msg_count,
     x_msg_data	   => l_msg_data,
     p_subject		   => l_subject,
	p_source_code_id  => l_source_code_id,
     p_party_id	   => l_party_id,
     p_user_id		   => l_user_id,
     p_queue_response  => FND_API.G_TRUE,
     p_extended_header => l_extended_header,
     p_content_xml	   => l_content_xml,
     p_request_id	   => l_request_id
    );
 END submit_request;
 -- ***************************************************
END ast_colltrl_order_pkg;

/
