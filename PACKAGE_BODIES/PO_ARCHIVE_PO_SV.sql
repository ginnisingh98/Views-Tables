--------------------------------------------------------
--  DDL for Package Body PO_ARCHIVE_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ARCHIVE_PO_SV" AS
/* $Header: POXPAR1B.pls 120.0 2005/06/01 18:01:00 appldev noship $ */

/*
  DESCRIPTION:	   Archiving code for Purchase Order

  OWNER:           Diwas Kc

  CHANGE HISTORY:  Created  02/29/01  DKC
                   zxzhang  06/01/03  FPJ, Refactory Archiving API, Replaced with
                   package PO_DOCUMENT_ARCHIVE_GRP/PVT
*/


-- <FPJ Refactor Archiving API>
-- Replaced with packages PO_DOCUMENT_ARCHIVE_GRP/PVT
FUNCTION  ARCHIVE_PO (X_document_id IN NUMBER, X_document_type VARCHAR2, X_doc_subtype VARCHAR2)
RETURN VARCHAR2
IS

BEGIN
  RETURN ('N');
END;


END  PO_ARCHIVE_PO_SV;

/
