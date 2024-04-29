--------------------------------------------------------
--  DDL for Package POS_DROP_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_DROP_SHIP_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVDROS.pls 115.3 2004/05/13 22:32:33 swijesek noship $ */

 /*=======================================================================+
 | FILENAME
 |   POSVDROS.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  POS_DROP_SHIP_PVT
 |
 *=====================================================================*/

-- Start of comments
-- API name     : get_drop_ship_info
-- Type         : private
-- Pre-reqs     : none
-- Function     :
-- Parameters   :
-- IN           : po_header_id	in number	required
--                po_line_id	in mumber	required
--                line_location_id in number	required
-- 		  po_release_id	in number	required
-- OUT          :
-- Version      : initial version
-- End of comments

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
                               x_msg_data		out nocopy varchar2);


-- Start of comments
-- API name     : get_drop_ship_xml_info
-- Type         : private
-- Pre-reqs     : none
-- Function     :
-- Parameters   :
-- IN           : po_header_id	in number	required
--                po_line_id	in mumber	required
--                line_location_id in number	required
-- 		  po_release_id	in number	required
-- OUT          :
-- Version      : initial version
-- End of comments

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
 			       x_delto_contact_email  	out nocopy varchar2);

end POS_DROP_SHIP_PVT;

 

/
