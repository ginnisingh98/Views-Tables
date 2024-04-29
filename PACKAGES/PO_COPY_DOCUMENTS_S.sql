--------------------------------------------------------
--  DDL for Package PO_COPY_DOCUMENTS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPY_DOCUMENTS_S" AUTHID CURRENT_USER AS
/* $Header: POXDOCPS.pls 115.1 2002/11/26 19:49:15 sbull ship $*/
PROCEDURE copy_document   (x_po_header_id 		IN number,
			   x_new_document_type 		IN varchar2,
			   x_new_document_subtype 	IN varchar2,
			   x_new_supplier_id 		IN number,
			   x_new_supplier_site_id 	IN number,
			   x_new_supplier_contact_id 	IN number,
			   x_copy_mode 			IN varchar2,
			   x_copy_attachments 		IN varchar2,
			   x_new_document_num 		IN varchar2,
			   x_new_po_header_id 		OUT NOCOPY number,
			   x_actual_document_num        IN OUT NOCOPY varchar2);

END po_copy_documents_s;

 

/
