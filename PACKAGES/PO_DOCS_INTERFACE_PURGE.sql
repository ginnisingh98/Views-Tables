--------------------------------------------------------
--  DDL for Package PO_DOCS_INTERFACE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCS_INTERFACE_PURGE" AUTHID CURRENT_USER AS
/* $Header: POXPOIPS.pls 120.1 2005/10/18 12:22:25 bao noship $ */

/*================================================================

  PROCEDURE NAME: 	process_po_interface_tables()

==================================================================*/
PROCEDURE process_po_interface_tables(
			X_document_type               IN	VARCHAR2,
                        X_document_subtype            IN        VARCHAR2,
			X_accepted_flag		      IN	VARCHAR2,
			X_rejected_flag		      IN	VARCHAR2,
			X_start_date		      IN	DATE,
			X_end_date		      IN	DATE,
			X_selected_batch_id	      IN	NUMBER,
			p_org_id                      IN        NUMBER   DEFAULT NULL,     -- <R12 MOAC>
      p_po_header_id       IN NUMBER   DEFAULT NULL      -- <PDOI Rewrite>
			);

END PO_DOCS_INTERFACE_PURGE;

 

/
