--------------------------------------------------------
--  DDL for Package PO_ARCHIVE_DOCUMENT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ARCHIVE_DOCUMENT_SV" AUTHID CURRENT_USER AS
/* $Header: POXPIARS.pls 115.1 2002/11/23 02:59:17 sbull ship $ */


--
-- Archives the specified PO.
-- The procedure assumes that the document requires archving.
-- It does not perform any validation to check if archiving is required.
-- The calling program must do this validation.
--

PROCEDURE  Archive_PO (X_po_header_id IN NUMBER, X_result OUT NOCOPY BOOLEAN);

end PO_ARCHIVE_DOCUMENT_SV;

 

/
