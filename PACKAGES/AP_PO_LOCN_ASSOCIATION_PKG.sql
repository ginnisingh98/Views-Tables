--------------------------------------------------------
--  DDL for Package AP_PO_LOCN_ASSOCIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PO_LOCN_ASSOCIATION_PKG" AUTHID CURRENT_USER AS
/* $Header: appolocs.pls 120.2 2004/10/28 23:28:18 pjena noship $ */
--
--
PROCEDURE insert_row (	p_location_id 			IN NUMBER,
			p_vendor_id   			IN NUMBER,
			p_vendor_site_id 		IN NUMBER,
			p_last_update_date 		IN DATE,
			p_last_updated_by  		IN NUMBER,
			p_last_update_login 		IN NUMBER,
			p_creation_date 		IN DATE,
			p_created_by 			IN NUMBER,
			p_org_id			IN NUMBER);  /* MO Access Control */

PROCEDURE update_row ( 	p_location_id 			IN NUMBER,
			p_vendor_id   			IN NUMBER,
			p_vendor_site_id 		IN NUMBER,
			p_last_update_date 		IN DATE,
			p_last_updated_by  		IN NUMBER,
			p_last_update_login 		IN NUMBER,
			p_creation_date 		IN DATE,
			p_created_by 			IN NUMBER,
			p_org_id			IN NUMBER);  /* MO Access Control */

END ap_po_locn_association_pkg;

 

/
