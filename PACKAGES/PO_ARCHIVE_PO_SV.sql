--------------------------------------------------------
--  DDL for Package PO_ARCHIVE_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ARCHIVE_PO_SV" AUTHID CURRENT_USER AS
/* $Header: POXPAR1S.pls 120.0 2005/06/02 00:16:04 appldev noship $ */

--
-- Archives the specified PO.
-- This package includes procedures that check to see if the PO needs to be archived.
-- Based on the type of document (PO, PA, RELEASE) and document subtype, different
-- archiving routines are called.
--

-- <FPJ Refactor Archiving API>
-- Replaced with packages PO_DOCUMENT_ARCHIVE_GRP/PVT

FUNCTION  ARCHIVE_PO(X_document_id IN NUMBER, X_document_type VARCHAR2, x_doc_subtype varchar2) return varchar2;

end PO_ARCHIVE_PO_SV;

 

/
