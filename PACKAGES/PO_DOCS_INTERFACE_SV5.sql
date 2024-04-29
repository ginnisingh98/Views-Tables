--------------------------------------------------------
--  DDL for Package PO_DOCS_INTERFACE_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCS_INTERFACE_SV5" AUTHID CURRENT_USER AS
/* $Header: POXPIDIS.pls 120.1 2005/12/16 16:27:14 bao noship $ */

/*==================================================================
  PROCEDURE NAME:  process_po_headers_interface()

  DESCRIPTION:    This API is used to process records in po_headers_interface.
                  it will call derivation, defaulting and validation subprog
                  and populate records into po_headers, and at the same time,
                  to process line.

  PARAMETERS:


  DESIGN
  REFERENCES:     832proc.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan Odayar
                  Modified      04-MAR-1996     Daisy Yu
		  Modified	18-Jun-1996	KKCHAN
			* added x_rel_gen_method as one parameter.
			            Modified      03-Aug-2005     BAO  -- <PDOI Rewrite R12>

=======================================================================*/
PROCEDURE process_po_headers_interface(
                        X_selected_batch_id	      IN	NUMBER,
                        X_buyer_id		      IN	NUMBER,
                        X_document_type               IN	VARCHAR2,
                        X_document_subtype            IN        VARCHAR2,
                        X_create_items                IN	VARCHAR2,
                        X_create_sourcing_rules_flag  IN	VARCHAR2,
                        X_rel_gen_method	      IN	VARCHAR2,
                        X_approved_status             IN	VARCHAR2,
                        X_commit_interval	      IN	NUMBER,
                        X_process_code		      IN	VARCHAR2,
                        X_interface_header_id         IN        NUMBER default NULL,
                        X_org_id_param                IN        NUMBER default NULL,
                        X_ga_flag                     IN        VARCHAR2 default 'N',
----<LOCAL SR/ASL PROJECT 11i11 START>
                        p_sourcing_level		  IN VARCHAR2 DEFAULT NULL,
                        p_inv_org_id	 	  IN PO_HEADERS_INTERFACE.org_id%type DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>
                        ); -- FPI



END PO_DOCS_INTERFACE_SV5;

 

/
