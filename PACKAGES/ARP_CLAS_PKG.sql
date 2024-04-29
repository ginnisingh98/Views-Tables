--------------------------------------------------------
--  DDL for Package ARP_CLAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CLAS_PKG" AUTHID CURRENT_USER AS
/* $Header: AROCLASS.pls 120.3.12010000.2 2008/11/19 11:38:55 ankuagar ship $ */

PROCEDURE check_unique_inv_location (  p_inventory_location_id in number,
                                       x_return_status         out nocopy varchar2,
                                       x_msg_count             out nocopy number,
                                       x_msg_data              out nocopy varchar2,
				       l_org_id                in number
                                     );

procedure insert_po_loc_associations (	p_inventory_location_id		in number,
					p_inventory_organization_id	in number,
					p_customer_id 			in number,
					p_address_id			in number,
					p_site_use_id			in number,
                                        x_return_status                 out nocopy varchar2,
                                        x_msg_count                     out nocopy number,
                                        x_msg_data                      out nocopy varchar2
					);


procedure update_po_loc_associations ( 	p_site_use_id 			in number,
					p_address_id  			in number,
					p_customer_id 			in number,
					p_inventory_organization_id 	in number,
					p_inventory_location_id 	in number,
                                        x_return_status                 out nocopy varchar2,
                                        x_msg_count                     out nocopy number,
                                        x_msg_data                      out nocopy varchar2
                                     );

PROCEDURE check_unique_inv_location (  p_inventory_location_id in number );

procedure insert_po_loc_associations (  p_inventory_location_id         in number,
                                        p_inventory_organization_id     in number,
                                        p_customer_id                   in number,
                                        p_address_id                    in number,
                                        p_site_use_id                   in number
                                        );

procedure update_po_loc_associations (  p_site_use_id                   in number,
                                        p_address_id                    in number,
                                        p_customer_id                   in number,
                                        p_inventory_organization_id     in number,
                                        p_inventory_location_id         in number );
END arp_clas_pkg;

/
