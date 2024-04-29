--------------------------------------------------------
--  DDL for Package JAI_RCV_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_utils.pls 120.1 2005/07/20 12:59:23 avallabh ship $ */
  FUNCTION get_orgn_type_flags (p_location_id number,
                                p_organization_id number,
                                p_subinventory varchar2)
  RETURN VARCHAR2;

  PROCEDURE get_rg1_location (p_location_id number,
                               p_organization_id number,
                               p_subinventory varchar2,
                               p_rg_location_id OUT NOCOPY number);
/*  PRAGMA RESTRICT_REFERENCES (get_rg1_location, WNDS, WNPS); */

  PROCEDURE get_div_range (p_vendor_id number,
		    p_vendor_site_id number,
		    p_range_no OUT NOCOPY varchar2,
		    p_division_no OUT NOCOPY varchar2);

  PROCEDURE get_func_curr (p_organization_id number,
                            p_func_currency OUT NOCOPY varchar2,
                            p_gl_set_of_books_id OUT NOCOPY number);

  PROCEDURE get_organization (p_shipment_line_id in number,
                               p_organization_id OUT NOCOPY number,
                               p_item_id OUT NOCOPY number);

  PROCEDURE get_location (p_location_id number,
                           p_organization_id number,
                           p_subinventory varchar2,
                           p_rg_location_id OUT NOCOPY number);


END jai_rcv_utils_pkg;
 

/
