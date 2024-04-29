--------------------------------------------------------
--  DDL for Package Body OE_INSTALL_BASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INSTALL_BASE_UTIL" AS
/* $Header: OEXUINSB.pls 120.2 2006/06/23 22:06:40 sdatti noship $*/


  PROCEDURE get_partner_ord_rec(
    p_order_line_id     IN  number,
    x_partner_order_rec OUT NOCOPY partner_order_rec)
  IS
  BEGIN

    SELECT oel.IB_OWNER,
           oel.IB_INSTALLED_AT_LOCATION,
           oel.IB_CURRENT_LOCATION,
           nvl(oel.END_CUSTOMER_ID,oeh.END_CUSTOMER_ID),
           nvl(oel.END_CUSTOMER_CONTACT_ID,oeh.END_CUSTOMER_CONTACT_ID),
           nvl(oel.END_CUSTOMER_SITE_USE_ID,oeh.END_CUSTOMER_SITE_USE_ID),
           oeh.sold_to_site_use_id
    INTO   x_partner_order_rec.IB_OWNER,
           x_partner_order_rec.IB_INSTALLED_AT_LOCATION,
           x_partner_order_rec.IB_CURRENT_LOCATION,
           x_partner_order_rec.END_CUSTOMER_ID,
           x_partner_order_rec.END_CUSTOMER_CONTACT_ID,
           x_partner_order_rec.END_CUSTOMER_SITE_USE_ID,
           x_partner_order_rec.SOLD_TO_SITE_USE_ID
    FROM   oe_order_lines_all oel,
           oe_order_headers_all oeh
    WHERE  oel.line_id = p_order_line_id
    AND    oeh.header_id = oel.header_id;

  END get_partner_ord_rec;

  PROCEDURE return_selected_instances(
    l_returned_inst_tbl IN  csi_datastructures_pub.instance_cz_tbl)
  IS
  BEGIN

    g_returned_inst_tbl := l_returned_inst_tbl;

  END return_selected_instances;

  PROCEDURE get_returned_instances(
    l_read_inst_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_cz_tbl )
 is

  BEGIN
 for j in  1..g_returned_inst_tbl.count loop
   l_read_inst_tbl(j).item_instance_id           :=g_returned_inst_tbl(j).item_instance_id;
   l_read_inst_tbl(j).config_instance_hdr_id     :=g_returned_inst_tbl(j).config_instance_hdr_id;
   l_read_inst_tbl(j).config_instance_rev_number :=g_returned_inst_tbl(j).config_instance_rev_number;
   l_read_inst_tbl(j).config_instance_item_id :=g_returned_inst_tbl(j).config_instance_item_id;
   l_read_inst_tbl(j).bill_to_site_use_id        :=g_returned_inst_tbl(j).bill_to_site_use_id;
   l_read_inst_tbl(j).ship_to_site_use_id        :=g_returned_inst_tbl(j).ship_to_site_use_id;
   l_read_inst_tbl(j).instance_name              :=g_returned_inst_tbl(j).instance_name;
 end loop;
 END get_returned_instances;


END oe_install_base_util;

/
