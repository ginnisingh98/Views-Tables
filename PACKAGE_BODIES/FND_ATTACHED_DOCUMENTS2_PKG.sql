--------------------------------------------------------
--  DDL for Package Body FND_ATTACHED_DOCUMENTS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ATTACHED_DOCUMENTS2_PKG" as
/* $Header: AFAKATDB.pls 120.7.12010000.2 2010/02/16 22:18:06 ctilley ship $ */



--  API to delete attachments for a given entity
PROCEDURE delete_attachments(X_entity_name IN VARCHAR2,
		X_pk1_value IN VARCHAR2,
		X_pk2_value IN VARCHAR2 DEFAULT NULL,
		X_pk3_value IN VARCHAR2 DEFAULT NULL,
		X_pk4_value IN VARCHAR2 DEFAULT NULL,
		X_pk5_value IN VARCHAR2 DEFAULT NULL,
		X_delete_document_flag IN VARCHAR2,
		X_automatically_added_flag IN VARCHAR2 DEFAULT NULL) IS
l_delete_document_flag varchar2(1);

BEGIN
  l_delete_document_flag := X_delete_document_flag;
  IF l_delete_document_flag IS NULL THEN
    l_delete_document_flag := 'N';
  END IF;
  --  Check that entity_name and pk1_value have values
  IF (X_entity_name IS NULL
	OR X_pk1_value IS NULL) THEN
		RETURN;
  END IF;

  --  If X_delete_doc_flag is Y, then need to delete
  --  document records too
  IF X_pk2_value IS NULL THEN -- performance change IF.

  IF (l_delete_document_flag = 'Y') THEN
	--  need to delete from each sub-table holding the data
	--  doing this in a loop to reduce amount of code
 	DELETE FROM fnd_documents_short_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 1
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value);


 	DELETE FROM fnd_documents_long_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 2
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value);

 	DELETE FROM fnd_documents_long_raw
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id IN (3,4)
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value);

         DELETE FROM fnd_lobs
         WHERE file_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 6
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value);

	--  Delete from FND_DOCUMENTS_TL table
	DELETE FROM fnd_documents_tl
	 WHERE document_id IN
	(SELECT fad.document_id
	FROM fnd_attached_documents fad, fnd_documents fd
	WHERE fad.document_id = fd.document_id
	AND fd.usage_type = 'O'
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value);

	--  Delete from FND_DOCUMENTS table
	DELETE FROM fnd_documents
	WHERE usage_type = 'O'
	 AND document_id IN
		(SELECT document_id
	           FROM fnd_attached_documents fad
		WHERE fad.entity_name = X_entity_name
		AND fad.pk1_value = X_pk1_value);
  END IF;  --  end of if l_delete_document_flag is Y

  --  delete from FND_ATTACHED_DOCUMENTS table
	DELETE FROM fnd_attached_documents fad
	  WHERE fad.entity_name = X_entity_name
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
	    AND fad.pk1_value = X_pk1_value;

  ELSIF X_pk3_value IS NULL THEN  --  performance change IF
      IF (l_delete_document_flag = 'Y') THEN
	--  need to delete from each sub-table holding the data
	--  doing this in a loop to reduce amount of code
 	DELETE FROM fnd_documents_short_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 1
	AND fad.entity_name = X_entity_name
        AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);


 	DELETE FROM fnd_documents_long_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 2
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);

 	DELETE FROM fnd_documents_long_raw
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id IN (3,4)
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);

         DELETE FROM fnd_lobs
         WHERE file_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 6
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);

	--  Delete from FND_DOCUMENTS_TL table
	DELETE FROM fnd_documents_tl
	 WHERE document_id IN
	(SELECT fad.document_id
	FROM fnd_attached_documents fad, fnd_documents fd
	WHERE fad.document_id = fd.document_id
	AND fd.usage_type = 'O'
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);

	--  Delete from FND_DOCUMENTS table
	DELETE FROM fnd_documents
	WHERE usage_type = 'O'
	 AND document_id IN
		(SELECT document_id
	           FROM fnd_attached_documents fad
		WHERE fad.entity_name = X_entity_name
		AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value);
  END IF;  --  end of if l_delete_document_flag is Y

  --  delete from FND_ATTACHED_DOCUMENTS table
	DELETE FROM fnd_attached_documents fad
	  WHERE fad.entity_name = X_entity_name
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
	    AND fad.pk1_value = X_pk1_value
	AND fad.pk2_value = X_pk2_value;

  ELSIF X_pk4_value IS NULL THEN     -- performance change if
 IF (l_delete_document_flag = 'Y') THEN
	--  need to delete from each sub-table holding the data
	--  doing this in a loop to reduce amount of code
 	DELETE FROM fnd_documents_short_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 1
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value);


 	DELETE FROM fnd_documents_long_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 2
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value);

 	DELETE FROM fnd_documents_long_raw
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id IN (3,4)
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value);

         DELETE FROM fnd_lobs
         WHERE file_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 6
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value);

	--  Delete from FND_DOCUMENTS_TL table
	DELETE FROM fnd_documents_tl
	 WHERE document_id IN
	(SELECT fad.document_id
	FROM fnd_attached_documents fad, fnd_documents fd
	WHERE fad.document_id = fd.document_id
	AND fd.usage_type = 'O'
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value);

	--  Delete from FND_DOCUMENTS table
	DELETE FROM fnd_documents
	WHERE usage_type = 'O'
	 AND document_id IN
		(SELECT document_id
	           FROM fnd_attached_documents fad
		WHERE fad.entity_name = X_entity_name
		AND fad.pk1_value = X_pk1_value
                AND fad.pk2_value = X_pk2_value
                AND fad.pk3_value = X_pk3_value);
  END IF;  --  end of if l_delete_document_flag is Y

  --  delete from FND_ATTACHED_DOCUMENTS table
	DELETE FROM fnd_attached_documents fad
	  WHERE fad.entity_name = X_entity_name
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
	    AND fad.pk1_value = X_pk1_value
            AND fad.pk2_value = X_pk2_value
            AND fad.pk3_value = X_pk3_value;

 ELSE      -- performance change if
 IF (l_delete_document_flag = 'Y') THEN
	--  need to delete from each sub-table holding the data
	--  doing this in a loop to reduce amount of code
 	DELETE FROM fnd_documents_short_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 1
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value
        OR  X_pk4_value IS NULL
        AND fad.pk4_value = X_pk4_value
        OR  X_pk5_value IS NULL
        AND fad.pk5_value = X_pk5_value);


 	DELETE FROM fnd_documents_long_text
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 2
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value
        OR  X_pk4_value IS NULL
        AND fad.pk4_value = X_pk4_value
        OR  X_pk5_value IS NULL
        AND fad.pk5_value = X_pk5_value);

 	DELETE FROM fnd_documents_long_raw
         WHERE media_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id IN (3,4)
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value
        OR  X_pk4_value IS NULL
        AND fad.pk4_value = X_pk4_value
        OR  X_pk5_value IS NULL
        AND fad.pk5_value = X_pk5_value);

         DELETE FROM fnd_lobs
         WHERE file_id IN
	(SELECT fd.media_id
 	  FROM fnd_documents_tl fdtl,
	       fnd_documents fd,
               fnd_attached_documents fad
	  WHERE fdtl.document_id = fd.document_id
	AND fd.document_id = fad.document_id
	AND fd.usage_type = 'O'
	AND fd.datatype_id = 6
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND fad.pk3_value = X_pk3_value
        OR  X_pk4_value IS NULL
        AND fad.pk4_value = X_pk4_value
        OR  X_pk5_value IS NULL
        AND fad.pk5_value = X_pk5_value);

	--  Delete from FND_DOCUMENTS_TL table
        --  BUG#5060588  added Parens around OR's.
	DELETE FROM fnd_documents_tl
	 WHERE document_id IN
	(SELECT fad.document_id
	FROM fnd_attached_documents fad, fnd_documents fd
	WHERE fad.document_id = fd.document_id
	AND fd.usage_type = 'O'
	AND fad.entity_name = X_entity_name
	AND fad.pk1_value = X_pk1_value
        AND fad.pk2_value = X_pk2_value
        AND (fad.pk3_value = X_pk3_value
        OR  X_pk4_value IS NULL)
        AND (fad.pk4_value = X_pk4_value
        OR  X_pk5_value IS NULL)
        AND fad.pk5_value = X_pk5_value);

	--  Delete from FND_DOCUMENTS table
        --  BUG#5060588  added Parens around OR's.
	DELETE FROM fnd_documents
	WHERE usage_type = 'O'
	 AND document_id IN
		(SELECT document_id
	           FROM fnd_attached_documents fad
		WHERE fad.entity_name = X_entity_name
		AND fad.pk1_value = X_pk1_value
                AND fad.pk2_value = X_pk2_value
                AND (fad.pk3_value = X_pk3_value
                OR  X_pk4_value IS NULL)
                AND (fad.pk4_value = X_pk4_value
                OR  X_pk5_value IS NULL)
                AND fad.pk5_value = X_pk5_value);
  END IF;  --  end of if l_delete_document_flag is Y

  --  delete from FND_ATTACHED_DOCUMENTS table
  --  BUG#5060588  added Parens around OR's.
	DELETE FROM fnd_attached_documents fad
	  WHERE fad.entity_name = X_entity_name
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
	    AND fad.pk1_value = X_pk1_value
            AND fad.pk2_value = X_pk2_value
            AND (fad.pk3_value = X_pk3_value
            OR  X_pk4_value IS NULL)
            AND (fad.pk4_value = X_pk4_value
            OR  X_pk5_value IS NULL)
            AND fad.pk5_value = X_pk5_value;

  END IF;   -- performance change IF

END delete_attachments;


--  API to copy attachments from one record to another
--  BUG#2790775
PROCEDURE copy_attachments(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS
  CURSOR docpk1 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title, fd.dm_node,
                fd.dm_folder_path,fd.dm_type, fd.dm_document_id,fd.dm_version_number
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fad.document_id = fd.document_id
	    AND fd.document_id = fdtl.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag);


CURSOR docpk2 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title, fd.dm_node,
                fd.dm_folder_path,fd.dm_type, fd.dm_document_id, fd.dm_version_number
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fad.document_id = fd.document_id
	    AND fd.document_id = fdtl.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND fad.pk2_value = X_from_pk2_value
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag);




CURSOR docpk3 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title, fd.dm_node,
                fd.dm_folder_path,fd.dm_type, fd.dm_document_id, fd.dm_version_number
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fad.document_id = fd.document_id
	    AND fd.document_id = fdtl.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND fad.pk2_value = X_from_pk2_value
            AND fad.pk3_value = X_from_pk3_value
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag);




CURSOR doclist IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title,  fd.dm_node,
                fd.dm_folder_path,fd.dm_type, fd.dm_document_id, fd.dm_version_number
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fad.document_id = fd.document_id
	    AND fd.document_id = fdtl.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND (X_from_pk2_value IS NULL
		 OR fad.pk2_value = X_from_pk2_value)
	    AND (X_from_pk3_value IS NULL
		 OR fad.pk3_value = X_from_pk3_value)
	    AND (X_from_pk4_value IS NULL
		 OR fad.pk4_value = X_from_pk4_value)
	    AND (X_from_pk5_value IS NULL
		 OR fad.pk5_value = X_from_pk5_value)
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag);




   CURSOR shorttext (mid NUMBER) IS
	SELECT short_text
	  FROM fnd_documents_short_text
	 WHERE media_id = mid;

   CURSOR longtext (mid NUMBER) IS
	SELECT long_text
	  FROM fnd_documents_long_text
	 WHERE media_id = mid;

   CURSOR fnd_lobs_cur (mid NUMBER) IS
        SELECT file_id,
               file_name,
               file_content_type,
               upload_date,
               expiration_date,
               program_name,
               program_tag,
               file_data,
               language,
               oracle_charset,
               file_format
        FROM fnd_lobs
        WHERE file_id = mid;

   media_id_tmp NUMBER;
   document_id_tmp NUMBER;
   row_id_tmp VARCHAR2(30);
   short_text_tmp VARCHAR2(4000);
   long_text_tmp VARCHAR2(32767);
   docrec doclist%ROWTYPE;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
BEGIN
	--  Use cursor loop to get all attachments associated with
	--  the from_entity
	IF (X_from_entity_name IS NULL OR X_from_pk1_value IS NULL) THEN
		RETURN;
        END IF;

        IF    X_from_pk2_value IS NULL THEN -- performance change IF
          OPEN docpk1;
        ELSIF X_from_pk3_value IS NULL THEN
          OPEN docpk2;
        ELSIF X_from_pk4_value IS NULL THEN
          OPEN docpk3;
        ELSE
          OPEN doclist;
        END IF;

        <<pkloop>>
        LOOP

          IF    X_from_pk2_value IS NULL THEN -- performance change IF
           FETCH docpk1 INTO docrec;
           --EXIT
           IF (docpk1%notfound) then
              EXIT pkloop;
           END IF;
          ELSIF X_from_pk3_value IS NULL THEN
           FETCH docpk2 INTO docrec;
           IF (docpk2%notfound) then
              EXIT pkloop;
           END IF;
          ELSIF X_from_pk4_value IS NULL THEN
           FETCH docpk3 INTO docrec;
           IF (docpk3%notfound) then
              EXIT pkloop;
           END IF;
          ELSE
           FETCH doclist INTO docrec;
           IF (doclist%notfound) then
              EXIT pkloop;
           END IF;
          END IF;

                --FOR docrec IN doclist LOOP
		--  One-Time docs that Short Text or Long Text will have
		--  to be copied into a new document (Long Text will be
		--  truncated to 32K).  Create the new document records
		--  before creating the attachment record
		--
		IF (docrec.usage_type = 'O'
		    AND docrec.datatype_id IN (1,2,5,6) ) THEN
			--  Create Documents records
			FND_DOCUMENTS_PKG.Insert_Row(row_id_tmp,
		                document_id_tmp,
				SYSDATE,
				NVL(X_created_by,0),
				SYSDATE,
				NVL(X_created_by,0),
				X_last_update_login,
				docrec.datatype_id,
				NVL(X_to_category_id, docrec.category_id),
				docrec.security_type,
				docrec.security_id,
				docrec.publish_flag,
				docrec.image_type,
				docrec.storage_type,
				docrec.usage_type,
				docrec.start_date_active,
				docrec.end_date_active,
				X_request_id,
				X_program_application_id,
				X_program_id,
				SYSDATE,
				docrec.language,
				docrec.description,
				docrec.file_name,
				media_id_tmp,
				docrec.dattr_cat, docrec.dattr1,
				docrec.dattr2, docrec.dattr3,
				docrec.dattr4, docrec.dattr5,
				docrec.dattr6, docrec.dattr7,
				docrec.dattr8, docrec.dattr9,
				docrec.dattr10, docrec.dattr11,
				docrec.dattr12, docrec.dattr13,
				docrec.dattr14, docrec.dattr15,
                                'N',docrec.url, docrec.title,
                                docrec.dm_node, docrec.dm_folder_path,
                                docrec.dm_type, docrec.dm_document_id,
                                docrec.dm_version_number);

			--  overwrite document_id from original
			--  cursor for later insert into
			--  fnd_attached_documents
			docrec.document_id := document_id_tmp;

			--  Duplicate short or long text
			IF (docrec.datatype_id = 1) THEN
				--  Handle short Text
				--  get original data
				OPEN shorttext(docrec.media_id);
				FETCH shorttext INTO short_text_tmp;
				CLOSE shorttext;

				INSERT INTO fnd_documents_short_text (
					media_id,
					short_text)
				 VALUES (
					media_id_tmp,
					short_text_tmp);
			media_id_tmp := '';

			ELSIF (docrec.datatype_id = 2) THEN
				--  Handle long text
				--  get original data
				OPEN longtext(docrec.media_id);
				FETCH longtext INTO long_text_tmp;
				CLOSE longtext;

				INSERT INTO fnd_documents_long_text (
					media_id,
					long_text)
				 VALUES (
					media_id_tmp,
					long_text_tmp);
			media_id_tmp := '';

		        ELSIF (docrec.datatype_id=6) THEN

                         OPEN fnd_lobs_cur(docrec.media_id);
                         FETCH fnd_lobs_cur
                           INTO fnd_lobs_rec.file_id,
                                fnd_lobs_rec.file_name,
                                fnd_lobs_rec.file_content_type,
                                fnd_lobs_rec.upload_date,
                                fnd_lobs_rec.expiration_date,
                                fnd_lobs_rec.program_name,
                                fnd_lobs_rec.program_tag,
                                fnd_lobs_rec.file_data,
                                fnd_lobs_rec.language,
                                fnd_lobs_rec.oracle_charset,
                                fnd_lobs_rec.file_format;
                         CLOSE fnd_lobs_cur;

             INSERT INTO fnd_lobs (
                                 file_id,
                                 file_name,
                                 file_content_type,
                                 upload_date,
                                 expiration_date,
                                 program_name,
                                 program_tag,
                                 file_data,
                                 language,
                                 oracle_charset,
                                 file_format)
               VALUES  (
                       media_id_tmp,
                       fnd_lobs_rec.file_name,
                       fnd_lobs_rec.file_content_type,
                       fnd_lobs_rec.upload_date,
                       fnd_lobs_rec.expiration_date,
                       fnd_lobs_rec.program_name,
                       fnd_lobs_rec.program_tag,
                       fnd_lobs_rec.file_data,
                       fnd_lobs_rec.language,
                       fnd_lobs_rec.oracle_charset,
                       fnd_lobs_rec.file_format);

                       media_id_tmp := '';

		  END IF;  -- end of duplicating text


		END IF;   --  end if usage_type = 'O' and datatype in (1,2,6)

		--  Create attachment record
		INSERT INTO fnd_attached_documents
		(attached_document_id,
		document_id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		seq_num,
		entity_name,
		pk1_value, pk2_value, pk3_value,
		pk4_value, pk5_value,
		automatically_added_flag,
		program_application_id, program_id,
		program_update_date, request_id,
		attribute_category, attribute1,
		attribute2, attribute3, attribute4,
		attribute5, attribute6, attribute7,
		attribute8, attribute9, attribute10,
		attribute11, attribute12, attribute13,
		attribute14, attribute15, column1, category_id) VALUES
		(fnd_attached_documents_s.nextval,
		docrec.document_id,
		sysdate,
		NVL(X_created_by,0),
		sysdate,
		NVL(X_created_by,0),
		X_last_update_login,
		docrec.seq_num,
		X_to_entity_name,
		X_to_pk1_value,
                X_to_pk2_value,
                X_to_pk3_value,
		X_to_pk4_value,
                X_to_pk5_value,
		docrec.automatically_added_flag,
		X_program_application_id, X_program_id,
		sysdate, X_request_id,
		docrec.attribute_category, docrec.attribute1,
		docrec.attribute2, docrec.attribute3,
		docrec.attribute4, docrec.attribute5,
		docrec.attribute6, docrec.attribute7,
		docrec.attribute8, docrec.attribute9,
		docrec.attribute10, docrec.attribute11,
		docrec.attribute12, docrec.attribute13,
		docrec.attribute14, docrec.attribute15,
		docrec.column1,
		NVL(X_to_category_id, NVL(docrec.att_cat, docrec.category_id)));

		--  Update the document to be a std document if it
		--  was an ole or image that wasn't already a std doc
		--  (images should be created as Std, but just in case)
		IF (docrec.datatype_id IN (3,4)
		    AND docrec.usage_type <> 'S') THEN
			UPDATE fnd_documents
			   SET usage_type = 'S'
			WHERE document_id = docrec.document_id;
		END IF;

	END LOOP;  --  end of working through all attachments
--  close cursors.
        IF    X_from_pk2_value IS NULL THEN -- performance change IF
          CLOSE docpk1;
        ELSIF X_from_pk3_value IS NULL THEN
          CLOSE docpk2;
        ELSIF X_from_pk4_value IS NULL THEN
          CLOSE docpk3;
        ELSE
          CLOSE doclist;
        END IF;

       EXCEPTION WHEN OTHERS THEN
       -- need to close all cursors
       CLOSE docpk1;
       CLOSE docpk2;
       CLOSE docpk3;
       CLOSE doclist;
       CLOSE shorttext;
       CLOSE longtext;
       CLOSE fnd_lobs_cur;

END copy_attachments;


END fnd_attached_documents2_pkg;

/
