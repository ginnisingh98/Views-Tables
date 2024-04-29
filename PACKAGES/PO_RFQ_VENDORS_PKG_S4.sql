--------------------------------------------------------
--  DDL for Package PO_RFQ_VENDORS_PKG_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQ_VENDORS_PKG_S4" AUTHID CURRENT_USER as
/* $Header: POXPIR5S.pls 115.0 99/07/17 01:50:15 porting ship $ */
            procedure check_unique_supplier_site
			(X_rowid                VARCHAR2,
			 X_vendor_id            NUMBER,
			 X_vendor_site_id       NUMBER,
			 X_po_header_id         NUMBER);
END PO_RFQ_VENDORS_PKG_S4;

 

/
