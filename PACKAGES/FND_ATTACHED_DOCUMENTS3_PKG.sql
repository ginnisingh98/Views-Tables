--------------------------------------------------------
--  DDL for Package FND_ATTACHED_DOCUMENTS3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ATTACHED_DOCUMENTS3_PKG" AUTHID CURRENT_USER as
/* $Header: AFAKAD3S.pls 115.5 2003/12/17 18:16:39 blash ship $ */


PROCEDURE check_unique(X_rowid VARCHAR2,
		       X_entity_name VARCHAR2,
			X_seq_num NUMBER,
			X_pkey1 VARCHAR2,
			X_pkey2 VARCHAR2,
			X_pkey3 VARCHAR2,
			X_pkey4 VARCHAR2,
			X_pkey5 VARCHAR2);

FUNCTION check_document_references(X_Document_id NUMBER)
RETURN BOOLEAN;

PROCEDURE delete_row (X_attached_document_id NUMBER,
		      X_datatype_id NUMBER,
		      delete_document_flag VARCHAR2 DEFAULT 'N' );

END fnd_attached_documents3_pkg;

 

/
