--------------------------------------------------------
--  DDL for Package PO_TOTALS_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TOTALS_PO_SV" AUTHID CURRENT_USER as
/* $Header: ICXPOTOS.pls 115.1 99/07/17 03:20:31 porting ship $ */

  FUNCTION get_po_total(X_header_id NUMBER)
	   return number;
  pragma restrict_references (get_po_total,WNDS,RNPS,WNPS);

  FUNCTION get_release_total(X_release_id NUMBER)
	   return number;
  pragma restrict_references (get_release_total,WNDS,RNPS,WNPS);

  FUNCTION get_po_archive_total(X_header_id NUMBER,
				X_revision_num NUMBER)
	   return number;
  pragma restrict_references (get_po_archive_total,WNDS,RNPS,WNPS);

  FUNCTION get_release_archive_total(X_release_id NUMBER,
				X_revision_num NUMBER)
	   return number;
  pragma restrict_references
	(get_release_archive_total,WNDS,RNPS,WNPS);

END PO_TOTALS_PO_SV;

 

/
