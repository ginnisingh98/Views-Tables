--------------------------------------------------------
--  DDL for Package PO_RFQ_VENDORS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQ_VENDORS_PKG_S3" AUTHID CURRENT_USER as
/* $Header: POXPIR4S.pls 115.0 99/07/17 01:50:07 porting ship $ */

  procedure check_unique(X_rowid		VARCHAR2,
			 X_sequence_num	        NUMBER,
			 X_po_header_id         NUMBER);

  FUNCTION get_max_sequence_num (X_po_header_id    NUMBER)
	 return number;

  --pragma restrict_references (get_max_sequence_num,WNDS,RNPS,WNPS);

END PO_RFQ_VENDORS_PKG_S3;

 

/
