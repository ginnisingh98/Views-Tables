--------------------------------------------------------
--  DDL for Package Body POS_DROP_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_DROP_SHIP_PVT" AS
/* $Header: POSVDROB.pls 120.1 2006/07/28 23:01:45 abtrived noship $ */

 /*=======================================================================+
 | FILENAME
 |   POSVDROB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  POS_DROP_SHIP_PVT
 |
 *=====================================================================*/



procedure get_drop_ship_info ( p_po_header_id        	in number,
                               p_po_line_id		in number,
                               p_line_location_id	in number,
                               p_po_release_id		in number,
                               x_customer_name		out nocopy varchar2,
                               x_contact_name		out nocopy varchar2,
                               x_customer_loc		out nocopy varchar2,
                               x_contact_phone		out nocopy varchar2,
                               x_contact_fax		out nocopy varchar2,
                               x_contact_email		out nocopy varchar2,
                               x_ship_method		out nocopy varchar2,
                               x_ship_instruct		out nocopy varchar2,
                               x_pack_instruct		out nocopy varchar2,
                               x_cust_po_num		out nocopy varchar2,
                               x_cust_line_num		out nocopy varchar2,
                               x_cust_ship_num		out nocopy varchar2,
                               x_product_desc		out nocopy varchar2,
                               x_delto_customer_name    out nocopy varchar2,
			       x_delto_contact_name     out nocopy varchar2,
			       x_delto_contact_phone    out nocopy varchar2,
			       x_delto_contact_fax      out nocopy varchar2,
                               x_delto_contact_email    out nocopy varchar2,
                               x_delto_address1		out nocopy varchar2,
                               x_delto_address2		out nocopy varchar2,
                               x_delto_city		out nocopy varchar2,
                               x_delto_state		out nocopy varchar2,
                               x_delto_zip		out nocopy varchar2,
                               x_delto_country		out nocopy varchar2,
                               x_return_status		out nocopy varchar2,
                               x_msg_data		out nocopy varchar2)
is
   l_drop_ship_rec  OE_DROP_SHIP_GRP.Order_Line_Info_Rec_Type;
   l_delto_addr varchar2(2000);
   l_msg_count number;
   l_return_status varchar2(100);
   l_delto_addr3 varchar2(100);
   l_delto_addr4 varchar2(100);
   l_org_id number;

begin

-- fix for bug 5417691 - adding code to set org_context
	select org_id
	into l_org_id
	from po_headers_all
	where po_header_id = p_po_header_id;

	fnd_client_info.set_org_context(to_char(l_org_id));
-- end fix

   OE_DROP_SHIP_GRP.Get_Order_Line_Info
   	       (p_api_version          => 1.0,
 		p_po_header_id         => p_po_header_id,
 		p_po_line_id           => p_po_line_id,
 		p_po_line_location_id  => p_line_location_id,
 		p_po_release_id        => p_po_release_id,
 		p_mode                 => 2,
 		x_order_line_info_rec  => l_drop_ship_rec,
 		x_msg_data             => x_msg_data,
 		x_msg_count            => l_msg_count,
 		x_return_status	       => x_return_status
 		);

   if (x_return_status = 'S' or x_return_status IS NULL) then
      x_customer_name := l_drop_ship_rec.ship_to_customer_name;
      x_contact_name := l_drop_ship_rec.ship_to_contact_name;
      x_customer_loc := l_drop_ship_rec.ship_to_customer_location;
      x_contact_phone := l_drop_ship_rec.ship_to_contact_phone;
      x_contact_fax := l_drop_ship_rec.ship_to_contact_fax;
      x_contact_email := l_drop_ship_rec.ship_to_contact_email;
      x_ship_method := l_drop_ship_rec.shipping_method;
      x_ship_instruct := l_drop_ship_rec.shipping_instructions;
      x_pack_instruct := l_drop_ship_rec.packing_instructions;
      x_product_desc := l_drop_ship_rec.customer_product_description;
      x_cust_po_num := l_drop_ship_rec.customer_po_number;
      x_cust_line_num := l_drop_ship_rec.customer_po_line_number;
      x_cust_ship_num := l_drop_ship_rec.customer_po_shipment_number;
      x_delto_customer_name := l_drop_ship_rec.deliver_to_customer_name;
      x_delto_contact_name := l_drop_ship_rec.deliver_to_contact_name;
      x_delto_contact_phone := l_drop_ship_rec.deliver_to_contact_phone;
      x_delto_contact_fax := l_drop_ship_rec.deliver_to_contact_fax;
      x_delto_contact_email := l_drop_ship_rec.deliver_to_contact_email;
      l_delto_addr := l_drop_ship_rec.deliver_to_customer_address;

      x_delto_address1 := l_drop_ship_rec.deliver_to_customer_address1;
      x_delto_address2 := l_drop_ship_rec.deliver_to_customer_address2;
      l_delto_addr3 := l_drop_ship_rec.deliver_to_customer_address3;
      if (l_delto_addr3 is not null) then
         x_delto_address2 := x_delto_address2 || ' ' || l_delto_addr3;
      end if;
      l_delto_addr4 := l_drop_ship_rec.deliver_to_customer_address4;
      if (l_delto_addr4 is not null) then
         x_delto_address2 := x_delto_address2 || ' ' || l_delto_addr4;
      end if;

      x_delto_city := l_drop_ship_rec.deliver_to_customer_city;
      x_delto_state := l_drop_ship_rec.deliver_to_customer_state;
      x_delto_zip := l_drop_ship_rec.deliver_to_customer_zip;
      x_delto_country := l_drop_ship_rec.deliver_to_customer_country;
   end if;

exception
   when others then
       raise_application_error(-20001, 'get_drop_ship_info: '||x_return_status||' '||x_msg_data||' ' ||SQLERRM,true);


end get_drop_ship_info;


procedure get_drop_ship_xml_info (p_po_header_id        in number,
                               p_po_line_id		in number,
                               p_line_location_id	in number,
                               p_po_release_id		in number,
                               x_customer_name		out nocopy varchar2,
                               x_contact_name		out nocopy varchar2,
                               x_contact_phone		out nocopy varchar2,
                               x_contact_fax		out nocopy varchar2,
                               x_contact_email		out nocopy varchar2,
                               x_ship_method		out nocopy varchar2,
                               x_ship_instruct		out nocopy varchar2,
                               x_pack_instruct		out nocopy varchar2,
                               x_cust_po_num		out nocopy varchar2,
                               x_cust_line_num		out nocopy varchar2,
                               x_cust_ship_num		out nocopy varchar2,
                               x_product_desc		out nocopy varchar2,
                               x_delto_customer_name    out nocopy varchar2,
			       x_delto_customer_addr    out nocopy varchar2,
			       x_delto_customer_loc   	out nocopy varchar2,
			       x_delto_contact_name   	out nocopy varchar2,
			       x_delto_contact_phone  	out nocopy varchar2,
			       x_delto_contact_fax    	out nocopy varchar2,
 			       x_delto_contact_email  	out nocopy varchar2)

is
   l_drop_ship_rec  OE_DROP_SHIP_GRP.Order_Line_Info_Rec_Type;
   l_msg_data varchar2(2000);
   l_msg_count number;
   l_return_status varchar2(100);
   l_org_id number;

begin

-- fix for bug 5417691 - adding code to set org_context
	select org_id
	into l_org_id
	from po_headers_all
	where po_header_id = p_po_header_id;

	fnd_client_info.set_org_context(to_char(l_org_id));
-- end fix

   OE_DROP_SHIP_GRP.Get_Order_Line_Info
   	       (p_api_version          => 1.0,
 		p_po_header_id         => p_po_header_id,
 		p_po_line_id           => p_po_line_id,
 		p_po_line_location_id  => p_line_location_id,
 		p_po_release_id        => p_po_release_id,
 		p_mode                 => 2,
 		x_order_line_info_rec  => l_drop_ship_rec,
 		x_msg_data             => l_msg_data,
 		x_msg_count            => l_msg_count,
 		x_return_status	       => l_return_status
 		);

   if (l_return_status = 'S' or l_return_status IS NULL) then
   	x_customer_name := l_drop_ship_rec.ship_to_customer_name;
   	x_contact_name := l_drop_ship_rec.ship_to_contact_name;
   	x_contact_phone := l_drop_ship_rec.ship_to_contact_phone;
   	x_contact_fax := l_drop_ship_rec.ship_to_contact_fax;
   	x_contact_email := l_drop_ship_rec.ship_to_contact_email;
   	x_ship_method := l_drop_ship_rec.shipping_method;
   	x_ship_instruct := l_drop_ship_rec.shipping_instructions;
   	x_pack_instruct := l_drop_ship_rec.packing_instructions;
   	x_product_desc := l_drop_ship_rec.customer_product_description;
   	x_cust_po_num := l_drop_ship_rec.customer_po_number;
   	x_cust_line_num := l_drop_ship_rec.customer_po_line_number;
   	x_cust_ship_num := l_drop_ship_rec.customer_po_shipment_number;
   	x_delto_customer_name := l_drop_ship_rec.deliver_to_customer_name;
   	x_delto_customer_addr := l_drop_ship_rec.deliver_to_customer_address;
   	x_delto_customer_loc := l_drop_ship_rec.deliver_to_customer_Location;
   	x_delto_contact_name := l_drop_ship_rec.deliver_to_contact_name;
   	x_delto_contact_phone := l_drop_ship_rec.deliver_to_contact_phone;
   	x_delto_contact_fax := l_drop_ship_rec.deliver_to_contact_fax;
   	x_delto_contact_email := l_drop_ship_rec.deliver_to_contact_email;
   end if;

exception
   when others then
      wf_core.context('POS_DROP_SHIP_PVT','get_drop_ship_xml_info',SQLERRM);
      null;  --We don't want to raise the exception here as it will stop generation of XML

end get_drop_ship_xml_info;

end POS_DROP_SHIP_PVT;

/
