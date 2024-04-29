--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENTS_SV" as
/* $Header: POXDOTYB.pls 115.2 2002/11/23 03:30:29 sbull ship $ */
/*=============================  po_documents_sv  ===========================*/

/*===========================================================================

  PROCEDURE NAME:	get_doc_type_info

===========================================================================*/
PROCEDURE get_doc_type_info ( x_doc_type_code      IN  VARCHAR2,
                              x_doc_subtype        IN  VARCHAR2,
			      x_type_name	   OUT NOCOPY VARCHAR2) IS
    x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;

  SELECT podt.type_name
  INTO   x_type_name
  FROM   po_document_types podt
  WHERE  podt.document_type_code = x_doc_type_code
  AND    podt.document_subtype   = x_doc_subtype;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_doc_type_info', x_progress, sqlcode);
    raise;

end get_doc_type_info;



/*===========================================================================

  PROCEDURE NAME:	get_doc_security_level

===========================================================================*/
PROCEDURE get_doc_security_level ( x_doc_type_code      IN  VARCHAR2,
                                   x_doc_subtype        IN  VARCHAR2,
			           x_security_level	OUT NOCOPY VARCHAR2) IS
    x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;

  SELECT podt.security_level_code
  INTO   x_security_level
  FROM   po_document_types podt
  WHERE  podt.document_type_code = x_doc_type_code
  AND    podt.document_subtype   = x_doc_subtype;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_doc_security_level', x_progress, sqlcode);
    raise;

end get_doc_security_level;



/*===========================================================================

  PROCEDURE NAME:	get_doc_access_level

===========================================================================*/
PROCEDURE get_doc_access_level ( x_doc_type_code      IN  VARCHAR2,
                                 x_doc_subtype        IN  VARCHAR2,
			         x_access_level       OUT NOCOPY VARCHAR2) IS
    x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;

  SELECT podt.access_level_code
  INTO   x_access_level
  FROM   po_document_types podt
  WHERE  podt.document_type_code = x_doc_type_code
  AND    podt.document_subtype   = x_doc_subtype;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_doc_access_level', x_progress, sqlcode);
    raise;

end get_doc_access_level;


END PO_DOCUMENTS_SV;

/
