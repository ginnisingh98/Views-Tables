--------------------------------------------------------
--  DDL for Package Body FND_ATTACHED_DOCUMENTS3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ATTACHED_DOCUMENTS3_PKG" as
/* $Header: AFAKAD3B.pls 115.9 2003/12/17 18:16:27 blash ship $ */


PROCEDURE check_unique(X_rowid VARCHAR2,
		       X_entity_name VARCHAR2,
			X_seq_num NUMBER,
			X_pkey1 VARCHAR2,
			X_pkey2 VARCHAR2,
			X_pkey3 VARCHAR2,
			X_pkey4 VARCHAR2,
			X_pkey5 VARCHAR2) IS
 dummy number;
BEGIN

 IF (X_pkey2 is not null) and (X_pkey3 is not null) THEN
       SELECT COUNT(1) INTO DUMMY
	 FROM fnd_attached_documents
	  WHERE seq_num = X_seq_num
   	    AND entity_name = X_entity_name
	    AND pk1_value = X_pkey1
	    AND pk2_value = X_pkey2
	    AND pk3_value = X_pkey3
	    AND (X_pkey4 IS NULL
		 OR pk4_value = X_pkey4)
	    AND (X_pkey5 IS NULL
		 OR pk5_value = X_pkey5)
	    AND ( (X_rowid IS NULL) OR (rowid <> X_rowid) );

 ELSE IF (X_pkey2 is not null) THEN

       SELECT COUNT(1) INTO DUMMY
	 FROM fnd_attached_documents
	  WHERE seq_num = X_seq_num
   	    AND entity_name = X_entity_name
	    AND pk1_value = X_pkey1
	    AND pk2_value = X_pkey2
	    AND pk3_value IS NULL
	    AND (X_pkey4 IS NULL
		 OR pk4_value = X_pkey4)
	    AND (X_pkey5 IS NULL
		 OR pk5_value = X_pkey5)
	    AND ( (X_rowid IS NULL) OR (rowid <> X_rowid) );
  ELSE

	SELECT COUNT(1) INTO DUMMY
	 FROM fnd_attached_documents
	  WHERE seq_num = X_seq_num
   	    AND entity_name = X_entity_name
	    AND pk1_value = X_pkey1
	    AND (X_pkey2 IS NULL)
	    AND (X_pkey3 IS NULL)
	    AND (X_pkey4 IS NULL
		 OR pk4_value = X_pkey4)
	    AND (X_pkey5 IS NULL
		 OR pk5_value = X_pkey5)
	    AND ( (X_rowid IS NULL) OR (rowid <> X_rowid) );
 END IF;
END IF;

 IF (dummy >= 1) THEN
	FND_MESSAGE.set_name('FND', 'ATCHMT-DUPLICATE SEQ_NUM');
	APP_EXCEPTION.RAISE_EXCEPTION;
 END IF;

END check_unique;


FUNCTION check_document_references(X_Document_id NUMBER)
RETURN BOOLEAN IS
 reference_count NUMBER;
BEGIN

  SELECT count(*)
    INTO reference_count
    FROM fnd_attached_documents
   WHERE document_id = X_document_id;

  IF (reference_count > 0) THEN
	RETURN(TRUE);
  ELSE
	RETURN(FALSE);
  END IF;

END check_document_references;

PROCEDURE delete_row (X_attached_document_id NUMBER,
		      X_datatype_id NUMBER,
		      delete_document_flag VARCHAR2 DEFAULT 'N' ) IS

 X_document_id NUMBER;

BEGIN
-- Get the Document Id before deleting the reference.

  IF (delete_document_flag = 'Y') THEN
	-- Get the document_id from fnd_attached_documents.

	SELECT document_id
	INTO   X_document_id
	FROM fnd_attached_documents
	WHERE attached_document_id = X_attached_document_id;

  END IF;


-- Delete the reference
  DELETE FROM fnd_attached_documents
   WHERE attached_document_id = X_attached_document_id;

-- Delete the document if the delete document flag is Y.
  IF (delete_document_flag = 'Y') THEN

	-- Delete the document
        IF (X_document_id > 0) THEN
		fnd_documents_pkg.delete_row (X_document_id,
					      X_datatype_id,
					      'N');
	END IF;

  END IF; /* Delete Document */

END delete_row ;

END fnd_attached_documents3_pkg;

/
