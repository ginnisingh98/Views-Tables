--------------------------------------------------------
--  DDL for Package PO_LINE_LOCATIONS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_LOCATIONS_PKG_S3" AUTHID CURRENT_USER as
/* $Header: POXP4PSS.pls 115.3 2004/03/09 23:28:41 dreddy ship $ */



  procedure check_unique(X_rowid		VARCHAR2,
			 X_shipment_num	        VARCHAR2,
			 X_po_line_id           NUMBER,
			 X_po_release_id        NUMBER,
                         X_shipment_type        VARCHAR2);

  -- Bug 3494974
  FUNCTION check_unique (	X_shipment_num	      VARCHAR2,
                        X_po_line_id           NUMBER,
                        X_shipment_type       VARCHAR2)
  RETURN BOOLEAN;

  function  select_summary(X_po_release_id IN number)
                           return NUMBER;

--  pragma restrict_references (select_summary, WNDS);

  FUNCTION get_max_shipment_num (X_po_line_id    NUMBER,
                                 X_po_release_id NUMBER,
                                 X_shipment_type VARCHAR2)
	 return number;

--  pragma restrict_references (get_max_shipment_num,WNDS,RNPS,WNPS);

END PO_LINE_LOCATIONS_PKG_S3;

 

/
