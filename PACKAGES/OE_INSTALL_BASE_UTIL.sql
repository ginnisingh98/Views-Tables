--------------------------------------------------------
--  DDL for Package OE_INSTALL_BASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INSTALL_BASE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUINSS.pls 120.1 2005/08/03 13:23:10 vmalapat noship $*/

-- This is the Global PL/SQL table for the returned set of Instances
-- From the Instance Query Form

g_returned_inst_tbl csi_datastructures_pub.instance_cz_tbl;

 -- This record holds the data that is selected from the Install Base Reconfiguration UI

 TYPE instance_rec_type IS RECORD
  (
      ITEM_INSTANCE_ID                  NUMBER               :=  NULL,
      CONFIG_INSTANCE_HDR_ID            NUMBER               :=  NULL,
      CONFIG_INSTANCE_REV_NUMBER        NUMBER               :=  NULL,
      CONFIG_INSTANCE_ITEM_ID           NUMBER               :=  NULL,
      -- Next 3 are optional
      BILL_TO_SITE_USE_ID               NUMBER               :=  NULL,
      SHIP_TO_SITE_USE_ID               NUMBER               :=  NULL,
      INSTANCE_NAME                     VARCHAR2(240)        :=  NULL
  );

 TYPE instance_tbl_type IS TABLE OF csi_datastructures_pub.instance_cz_rec
                           INDEX BY BINARY_INTEGER;


 -- This record type is used to populate the values for the new columns introduced
 -- in order_lines and order_header tables for 11.5.10.

 TYPE partner_order_rec IS RECORD
  (
      IB_OWNER                          VARCHAR2(30)         :=  NULL,
    -- Bug 3281397   IB_INSTALLED_AT_LOCATION          NUMBER               :=  NULL,
    -- Bug 3281397   IB_CURRENT_LOCATION               NUMBER               :=  NULL,
      IB_INSTALLED_AT_LOCATION          VARCHAR2(30)         :=  NULL,
      IB_CURRENT_LOCATION               VARCHAR2(30)         :=  NULL,
      END_CUSTOMER_ID                   NUMBER               :=  NULL,
      END_CUSTOMER_CONTACT_ID           NUMBER               :=  NULL,
      END_CUSTOMER_SITE_USE_ID          NUMBER               :=  NULL,
      SOLD_TO_SITE_USE_ID               NUMBER               :=  NULL
  );

 TYPE partner_order_tbl IS TABLE OF partner_order_rec INDEX BY BINARY_INTEGER;

 PROCEDURE get_partner_ord_rec (
              p_order_line_id      IN  number,
              x_partner_order_rec  OUT NOCOPY partner_order_rec);

  PROCEDURE return_selected_instances(
    l_returned_inst_tbl IN csi_datastructures_pub.instance_cz_tbl);

  PROCEDURE get_returned_instances(
    l_read_inst_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_cz_tbl );

END oe_install_base_util;

 

/
