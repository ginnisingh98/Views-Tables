--------------------------------------------------------
--  DDL for Package Body EDR_ATTACHMENTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ATTACHMENTS_GRP" AS
/*  $Header: EDRGATCB.pls 120.4.12000000.1 2007/01/18 05:53:18 appldev ship $ */

G_ENTITY_NAME constant varchar2(10) := 'ERECORD';
G_TEMP_ENTITY_NAME constant varchar2(15) := 'TEMPERECORD';
G_PUBLISH_FLAG_N constant varchar2(1) := 'N';
G_PUBLISH_FLAG_Y constant varchar2(1) := 'Y';
G_SECURITY_OFF constant NUMBER := 4;
G_SECURITY_ON constant NUMBER := 1;

-- Bug 4731317 :start
/*
-- Bug 4381237: Start
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
		fdtl.language, fdtl.description, fdtl.file_name,
		fdtl.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE fad.document_id = fd.document_id
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
   short_text_tmp VARCHAR2(2000);
   long_text_tmp LONG;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
BEGIN
  --  Use cursor loop to get all attachments associated with
  --  the from_entity
  FOR docrec IN doclist LOOP
    --  One-Time docs that Short Text or Long Text will have
    --  to be copied into a new document (Long Text will be
    --  truncated to 32K).  Create the new document records
    --  before creating the attachment record

    --Bug 4381237: Start
    --We are changing the logic of the FND copy atachment in the following manner:
    --1. make a new physical copy of the attachment even in case when its of type
    --   standard. But do this ONLY when the security on the base document is enforced
    --   i.e. when the security type <> 4 and security id <> null
    --IF (docrec.usage_type = 'O'
    --    AND docrec.datatype_id IN (1,2,5,6) ) THEN
    IF docrec.datatype_id IN (1,2,5,6) AND
      (
       (docrec.usage_type = 'S' and (docrec.security_type <> 4
                                     or (docrec.security_type = 4 and
                                         docrec.security_id is not NULL
                                        )
                                    )
       )
       OR
       docrec.usage_type = 'O'
      )

    THEN
    --Bug 4381237: End
      --  Create Documents records
      FND_DOCUMENTS_PKG.Insert_Row
      (row_id_tmp,
       document_id_tmp,
       SYSDATE,
       NVL(X_created_by,0),
       SYSDATE,
       NVL(X_created_by,0),
       X_last_update_login,
       docrec.datatype_id,
       NVL(X_to_category_id, docrec.category_id),
       --Bug 4381237: Start
       --security is always enforced as 4 and security id as null
       --docrec.security_type,
       4,
       --docrec.security_id,
       NULL,
       --Bug 4381237: End
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
       docrec.dattr14, docrec.dattr15);

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

        INSERT INTO fnd_documents_short_text
        (media_id,
	 short_text)
	VALUES
	(media_id_tmp,
	 short_text_tmp);

        media_id_tmp := '';
     ELSIF (docrec.datatype_id = 2) THEN
       --  Handle long text
       --  get original data
       OPEN longtext(docrec.media_id);
       FETCH longtext INTO long_text_tmp;
       CLOSE longtext;

       INSERT INTO fnd_documents_long_text
       (media_id,
	long_text)
       VALUES
       (media_id_tmp,
	long_text_tmp);

       media_id_tmp := '';
     ELSIF (docrec.datatype_id=6) THEN
       OPEN fnd_lobs_cur(docrec.media_id);
       FETCH fnd_lobs_cur INTO
         fnd_lobs_rec.file_id,
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

       INSERT INTO fnd_lobs
       (file_id,
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
       VALUES
       (media_id_tmp,
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
   END IF;   --  end if datatype in (1,2,6)

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
    attribute14, attribute15, column1, category_id)
   VALUES
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
    NVL(X_to_pk2_value, docrec.pk2_value),
    NVL(X_to_pk3_value, docrec.pk3_value),
    NVL(X_to_pk4_value, docrec.pk4_value),
    NVL(X_to_pk5_value, docrec.pk5_value),
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

 EXCEPTION WHEN OTHERS THEN

 CLOSE shorttext;
 CLOSE longtext;
 CLOSE fnd_lobs_cur;

END copy_attachments;
*/

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
BEGIN

		fnd_attached_documents2_pkg.copy_attachments(
			      X_from_entity_name,
			      X_from_pk1_value,
				X_from_pk2_value,
			      X_from_pk3_value,
			      X_from_pk4_value,
			      X_from_pk5_value,
			      X_to_entity_name,
			      X_to_pk1_value,
			      X_to_pk2_value,
			      X_to_pk3_value,
			      X_to_pk4_value,
			      X_to_pk5_value,
			      X_created_by,
			      X_last_update_login,
			      X_program_application_id,
			      X_program_id,
			      X_request_id,
			      X_automatically_added_flag,
			      X_from_category_id,
			      X_to_category_id);
  END;


-- Bug 4731317 : end
-- Bug 4731317 :start
/*
PROCEDURE copy_one_attachment(X_from_entity_name IN VARCHAR2,
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
			X_document_id IN NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS
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
		fdtl.language, fdtl.description, fdtl.file_name,
		fdtl.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  --WHERE fad.document_id = fd.document_id
	  WHERE	fad.document_id = X_document_id
	    AND fad.document_id = fd.document_id
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
   short_text_tmp VARCHAR2(2000);
   long_text_tmp LONG;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
BEGIN
  --  Use cursor loop to get all attachments associated with
  --  the from_entity
  FOR docrec IN doclist LOOP
    --  One-Time docs that Short Text or Long Text will have
    --  to be copied into a new document (Long Text will be
    --  truncated to 32K).  Create the new document records
    --  before creating the attachment record

    --Bug 4381237: Start
    --We are changing the logic of the FND copy atachment in the following manner:
    --1. make a new physical copy of the attachment even in case when its of type
    --   standard. But do this ONLY when the security on the base document is enforced
    --   i.e. when the security type <> 4 and security id <> null
    --IF (docrec.usage_type = 'O'
    --    AND docrec.datatype_id IN (1,2,5,6) ) THEN
    IF docrec.datatype_id IN (1,2,5,6) AND
      (
       (docrec.usage_type = 'S' and (docrec.security_type <> 4
                                     or (docrec.security_type = 4 and
                                         docrec.security_id is not NULL
                                        )
                                    )
       )
       OR
       docrec.usage_type = 'O'
      )

    THEN
    --Bug 4381237: End
      --  Create Documents records
      FND_DOCUMENTS_PKG.Insert_Row
      (row_id_tmp,
       document_id_tmp,
       SYSDATE,
       NVL(X_created_by,0),
       SYSDATE,
       NVL(X_created_by,0),
       X_last_update_login,
       docrec.datatype_id,
       NVL(X_to_category_id, docrec.category_id),
       --Bug 4381237: Start
       --security is always enforced as 4 and security id as null
       --docrec.security_type,
       4,
       --docrec.security_id,
       NULL,
       --Bug 4381237: End
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
       docrec.dattr14, docrec.dattr15);

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

        INSERT INTO fnd_documents_short_text
        (media_id,
	 short_text)
	VALUES
	(media_id_tmp,
	 short_text_tmp);

        media_id_tmp := '';
     ELSIF (docrec.datatype_id = 2) THEN
       --  Handle long text
       --  get original data
       OPEN longtext(docrec.media_id);
       FETCH longtext INTO long_text_tmp;
       CLOSE longtext;

       INSERT INTO fnd_documents_long_text
       (media_id,
	long_text)
       VALUES
       (media_id_tmp,
	long_text_tmp);

       media_id_tmp := '';
     ELSIF (docrec.datatype_id=6) THEN
       OPEN fnd_lobs_cur(docrec.media_id);
       FETCH fnd_lobs_cur INTO
         fnd_lobs_rec.file_id,
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

       INSERT INTO fnd_lobs
       (file_id,
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
       VALUES
       (media_id_tmp,
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
   END IF;   --  end if datatype in (1,2,6)

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
    attribute14, attribute15, column1, category_id)
   VALUES
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
    NVL(X_to_pk2_value, docrec.pk2_value),
    NVL(X_to_pk3_value, docrec.pk3_value),
    NVL(X_to_pk4_value, docrec.pk4_value),
    NVL(X_to_pk5_value, docrec.pk5_value),
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

 EXCEPTION WHEN OTHERS THEN

 CLOSE shorttext;
 CLOSE longtext;
 CLOSE fnd_lobs_cur;

END copy_one_attachment;

-- Bug 4381237 : End
*/
PROCEDURE copy_one_attachment(X_from_entity_name IN VARCHAR2,
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
			X_document_id IN NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS
BEGIN
		fnd_attached_documents2_pkg.copy_attachments(
			      X_from_entity_name,
			      X_from_pk1_value,
				X_from_pk2_value,
			      X_from_pk3_value,
			      X_from_pk4_value,
			      X_from_pk5_value,
			      X_to_entity_name,
			      X_to_pk1_value,
			      X_to_pk2_value,
			      X_to_pk3_value,
			      X_to_pk4_value,
			      X_to_pk5_value,
			      X_created_by,
			      X_last_update_login,
			      X_program_application_id,
			      X_program_id,
			      X_request_id,
			      X_automatically_added_flag,
			      X_from_category_id,
			      X_to_category_id);
END copy_one_attachment;
-- Bug 4731317 :end
PROCEDURE ATTACH_ERP_AUT(p_entity_name VARCHAR2,
				 p_pk1_value VARCHAR2,
				 p_pk2_value VARCHAR2,
				 p_pk3_value VARCHAR2,
				 p_pk4_value VARCHAR2,
				 p_pk5_value VARCHAR2,
				 p_category VARCHAR2,
                         p_target_value varchar2)
AS PRAGMA AUTONOMOUS_TRANSACTION;
	l_erecord_id number;
	l_pk2_value VARCHAR2(100);
	l_pk3_value VARCHAR2(100);
	l_pk4_value VARCHAR2(100);
	l_pk5_value VARCHAR2(100);
	l_category VARCHAR2(400);

      l_category_id NUMBER;
      l_category_names VARCHAR2(400);
      l_category_name VARCHAR2(30);
	l_user_id NUMBER;
	l_login_id NUMBER;
BEGIN
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','Inside Atonomous');
	l_user_id := fnd_global.user_id;
	l_login_id := fnd_global.login_id;
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','PK1 Value...'|| p_pk1_value);
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','PK2 Value...'|| p_pk2_value);
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','PK3 Value...'|| p_pk3_value);
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','PK4 Value...'|| p_pk4_value);
wf_log_pkg.string(6, 'ATTACH','PK5 Value...'|| p_pk5_value);


	if (upper(p_pk2_value) = '''NULL''') then
		l_pk2_value := NULL;
	else
		l_pk2_value := p_pk2_value;
	end if;

	if (upper(p_pk3_value) = '''NULL''') then
		l_pk3_value := NULL;
	else
		l_pk3_value := p_pk3_value;
	end if;

	if (upper(p_pk4_value) = '''NULL''') then
		l_pk4_value := NULL;
	else
		l_pk4_value := p_pk4_value;
	end if;

	if (upper(p_pk5_value) = '''NULL''') then
		l_pk5_value := NULL;
	else
		l_pk5_value := p_pk5_value;
	end if;

	if (upper(p_category) = '''NULL''') then
		l_category:= NULL;
	else
		l_category := p_category;
	end if;

	-- get the erecord id from the temporary table populate by the subscription
	-- rule function before invoking XML Gateway
	l_erecord_id := p_target_value;

	--obtain the name of the categories being passed from the call
	l_category_names := l_category;

	--parse the string of semicolon separated category names and get the
	--individual category name
	l_category_name := edr_utilities.get_delimited_string(l_category_names,';');

wf_log_pkg.string(6, 'ATTACH_ERP_AUT','Category PArsed');
	loop

		begin
			if (l_category_name is not null) then
				select category_id into l_category_id
				from fnd_document_categories_vl
				where name = l_category_name;
			end if;
wf_log_pkg.string(6, 'ATTACH_ERP_AUT','Calling Copy API');
			--call the fnd api to copy the attachment from the original
			--business entity to the ERECORD entity
			--change the category of the attachment to ERES

			-- call copy attachment for each category
      --Bug 4381237: Start
      --use the new copy attachment API from EDR instead of FND
      --fnd_attached_documents2_pkg.copy_attachments(
      copy_attachments(
      X_from_entity_name 		=> p_entity_name,
      X_from_pk1_value 			=> p_pk1_value,
      X_from_pk2_value 			=> l_pk2_value,
      X_from_pk3_value 			=> l_pk3_value,
      X_from_pk4_value 			=> l_pk4_value,
      X_from_pk5_value 			=> l_pk5_value,
      X_to_entity_name 			=> G_TEMP_ENTITY_NAME,
      X_to_pk1_value 			=> l_erecord_id,
      X_to_pk2_value 			=> null,
      X_to_pk3_value 			=> null,
      X_to_pk4_value 			=> null,
      X_to_pk5_value 			=> null,
      X_created_by 			=> l_user_id,
      X_last_update_login 		=> l_login_id,
      X_program_application_id 	=> null,
      X_program_id 			=> null,
      X_request_id 			=> null,
      X_automatically_added_flag 	=> 'N',
      X_from_category_id            => l_category_id,
      X_to_category_id              => l_category_id);
     --Bug 4381237: End
   exception
			when no_data_found then
		      wf_log_pkg.string(6, 'EDR_ATTACHMENTS_GRP.ATTACH_ERP_AUT','Category Not Found: '||l_category_name);
		end;

		--get the new value of the category name
		if (l_category_name is not null) then
			l_category_name := edr_utilities.get_delimited_string(l_category_names,';');
		end if;

		EXIT WHEN l_category_name is null;

	end loop;

	COMMIT;

END ATTACH_ERP_AUT;

PROCEDURE ATTACH_ERP (p_entity_name VARCHAR2,
			    p_pk1_value VARCHAR2,
			    p_pk2_value VARCHAR2,
			    p_pk3_value VARCHAR2,
			    p_pk4_value VARCHAR2,
			    p_pk5_value VARCHAR2,
			    p_category VARCHAR2) AS
  CURSOR GET_TEMP_EREC_ID IS
    select document_id
    from edr_erecord_id_temp;
  l_erecord_id number;
BEGIN
	-- get the erecord id from the temporary table populate by the subscription
	-- rule function before invoking XML Gateway
      wf_log_pkg.string(6, 'ATTACH_ERP','Inside Attachment Package');

      -- Bug 3186732
      -- Issue if XML Map has attachment procedure call then
      -- for those maps user used to get "NO DATA FOUND" Error
      -- because getting eRecord ID from edr_erecord_id_temp
      -- was using SELECT .. INTO .. for utility functions this
      -- row is not present it used give error
      -- modified the select statement and also added a condition
      -- to call copy attachments API only when eRecord ID is present.
      --

      OPEN GET_TEMP_EREC_ID;
      FETCH GET_TEMP_EREC_ID INTO l_erecord_id;
      CLOSE GET_TEMP_EREC_ID;

      wf_log_pkg.string(6, 'ATTACH_ERP','Event ID '||l_erecord_id);

      /* Call ATTACH_ERP_AUT only when temp eRecord ID present in GET_TEMP_EREC_ID */

      IF l_eRecord_id is not null THEN
         ATTACH_ERP_AUT(p_entity_name,p_pk1_value,p_pk2_value,p_pk3_value,p_pk4_value,
			   p_pk5_value,p_category,l_erecord_id);
      END IF;
END ATTACH_ERP;


PROCEDURE EVENT_POST_OP (p_file_id VARCHAR2) AS
	l_event_status VARCHAR2(15);
	l_status VARCHAR2(1);
	l_document_id NUMBER;
	l_publish BOOLEAN := FALSE;
	l_return_status  VARCHAR2(1);
	l_file_status VARCHAR2(1);
BEGIN
  --Bug 4374548: Start
  select status into l_file_status
  from edr_files_vl
  where file_id = p_file_id;
  --Bug 4374548: End

  --Bug 4374548: Added this if statement that encloses all processing
  if (l_file_status = 'P') then
    l_event_status := EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS;

    if (l_event_status = 'SUCCESS') then
      l_status := 'A';
      l_publish := TRUE;
    elsif (l_event_status = 'REJECTED') then
      l_status := 'R';
      --Bug 4086319: Start
      --Do not publish rejected documents.
      --l_publish := TRUE;
      --Bug 4086319: End
    elsif (l_event_status = 'TIMEDOUT') then
      l_status := 'N';
    end if;

    -- Bug 4090471 : Start
    EDR_ISIGN_CHECKLIST_PVT.ATTACH_CHECKLIST
    (p_file_id => p_file_id,
     x_return_status => l_return_status);
    -- Bug 4090471 : End

    UPDATE EDR_FILES_B
    SET STATUS = l_status
    where file_id = p_file_id;

    --publish the document existing in fnd tables if the file has been
    --approved or rejected
    if (l_publish = TRUE) then
      select fnd_document_id
      into l_document_id
      from edr_files_b
      where file_id = p_file_id;

      --this would allow the file to be attached to other business objects
      --through the Document Catalog button in the attachment Forms UI
      update fnd_documents set
      security_type = G_SECURITY_OFF,
      publish_flag = G_PUBLISH_FLAG_Y
      where document_id = l_document_id;
    end if;

    wf_event.raise2
    (p_event_name => 'oracle.apps.edr.file.approvalcompletion',
     p_event_key => p_file_id,
     p_event_data => null,
     p_parameter_name1 => 'FILE_STATUS',
     p_parameter_value1 => l_event_status
    );
  else
    wf_log_pkg.string(6, 'ATTACH_FILE_AUT','File status is not Pending.');
    wf_log_pkg.string(6, 'ATTACH_FILE_AUT','Cannot do any post op processing');
  end if;
EXCEPTION
  WHEN OTHERS THEN
    wf_log_pkg.string(6, 'ATTACH_FILE_AUT','Unexpected error in post op');
    wf_log_pkg.string(6, 'ATTACH_FILE_AUT',SQLERRM);
END EVENT_POST_OP;

PROCEDURE GET_CATEGORY_NAME (P_CATEGORY_NAME IN VARCHAR2,
				     P_DISPLAY_NAME in out nocopy VARCHAR2)
AS
BEGIN
wf_log_pkg.string(6, 'GET_CATEGORY_NAME','In the get_category_name procedure');

	SELECT USER_NAME INTO P_DISPLAY_NAME
	FROM FND_DOCUMENT_CATEGORIES_VL
	WHERE NAME = P_CATEGORY_NAME;
EXCEPTION WHEN NO_DATA_FOUND then
	P_DISPLAY_NAME := 'Invalid Category';

wf_log_pkg.string(6, 'GET_CATEGORY_NAME','Returning from get_category_name procedure');

END GET_CATEGORY_NAME;

PROCEDURE GET_DESC_FLEX_ALL_PROMPTS(P_APPLICATION_ID IN VARCHAR2,
	  			    P_DESC_FLEX_DEF_NAME IN  VARCHAR2,
				    P_DESC_FLEX_CONTEXT IN VARCHAR2,
				    P_PROMPT_TYPE IN VARCHAR2,
				    P_COLUMN1_NAME IN VARCHAR2,
				    P_COLUMN2_NAME IN VARCHAR2,
				    P_COLUMN3_NAME IN VARCHAR2,
				    P_COLUMN4_NAME IN VARCHAR2,
				    P_COLUMN5_NAME IN VARCHAR2,
				    P_COLUMN6_NAME IN VARCHAR2,
				    P_COLUMN7_NAME IN VARCHAR2,
				    P_COLUMN8_NAME IN VARCHAR2,
				    P_COLUMN9_NAME IN VARCHAR2,
				    P_COLUMN10_NAME IN VARCHAR2,
				    P_COLUMN1_PROMPT out nocopy VARCHAR2,
				    P_COLUMN2_PROMPT out nocopy VARCHAR2,
				    P_COLUMN3_PROMPT out nocopy VARCHAR2,
				    P_COLUMN4_PROMPT out nocopy VARCHAR2,
				    P_COLUMN5_PROMPT out nocopy VARCHAR2,
				    P_COLUMN6_PROMPT out nocopy VARCHAR2,
				    P_COLUMN7_PROMPT out nocopy VARCHAR2,
				    P_COLUMN8_PROMPT out nocopy VARCHAR2,
				    P_COLUMN9_PROMPT out nocopy VARCHAR2,
				    P_COLUMN10_PROMPT out nocopy VARCHAR2) AS
	L_PROMPT11 VARCHAR2(255);
	L_PROMPT12 VARCHAR2(255);
	L_PROMPT13 VARCHAR2(255);
	L_PROMPT14 VARCHAR2(255);
	L_PROMPT15 VARCHAR2(255);
	L_PROMPT16 VARCHAR2(255);
	L_PROMPT17 VARCHAR2(255);
	L_PROMPT18 VARCHAR2(255);
	L_PROMPT19 VARCHAR2(255);
	L_PROMPT20 VARCHAR2(255);
	L_PROMPT21 VARCHAR2(255);
	L_PROMPT22 VARCHAR2(255);
	L_PROMPT23 VARCHAR2(255);
	L_PROMPT24 VARCHAR2(255);
	L_PROMPT25 VARCHAR2(255);
	L_PROMPT26 VARCHAR2(255);
	L_PROMPT27 VARCHAR2(255);
	L_PROMPT28 VARCHAR2(255);
	L_PROMPT29 VARCHAR2(255);
	L_PROMPT30 VARCHAR2(255);

BEGIN
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','In the get_desc_flex_all_prompts procedure');

EDR_STANDARD.GET_DESC_FLEX_ALL_PROMPTS(
	P_APPLICATION_ID        => P_APPLICATION_ID,
	P_DESC_FLEX_DEF_NAME	=> P_DESC_FLEX_DEF_NAME,
	P_DESC_FLEX_CONTEXT	=> P_DESC_FLEX_CONTEXT,
	P_PROMPT_TYPE           => P_PROMPT_TYPE,
	P_COLUMN1_NAME          => P_COLUMN1_NAME,
	P_COLUMN2_NAME          => P_COLUMN2_NAME,
	P_COLUMN3_NAME          => P_COLUMN3_NAME,
	P_COLUMN4_NAME          => P_COLUMN4_NAME,
	P_COLUMN5_NAME          => P_COLUMN5_NAME,
	P_COLUMN6_NAME          => P_COLUMN6_NAME,
	P_COLUMN7_NAME          => P_COLUMN7_NAME,
	P_COLUMN8_NAME          => P_COLUMN8_NAME,
	P_COLUMN9_NAME          => P_COLUMN9_NAME,
	P_COLUMN10_NAME         => P_COLUMN10_NAME,
	P_COLUMN1_PROMPT        => P_COLUMN1_PROMPT,
	P_COLUMN2_PROMPT        => P_COLUMN2_PROMPT,
	P_COLUMN3_PROMPT        => P_COLUMN3_PROMPT,
	P_COLUMN4_PROMPT        => P_COLUMN4_PROMPT,
	P_COLUMN5_PROMPT        => P_COLUMN5_PROMPT,
	P_COLUMN6_PROMPT        => P_COLUMN6_PROMPT,
	P_COLUMN7_PROMPT        => P_COLUMN7_PROMPT,
	P_COLUMN8_PROMPT        => P_COLUMN8_PROMPT,
	P_COLUMN9_PROMPT        => P_COLUMN9_PROMPT,
	P_COLUMN10_PROMPT 	=> P_COLUMN10_PROMPT,
	P_COLUMN11_PROMPT	=> L_PROMPT11,
	P_COLUMN12_PROMPT	=> L_PROMPT12,
	P_COLUMN13_PROMPT	=> L_PROMPT13,
	P_COLUMN14_PROMPT	=> L_PROMPT14,
	P_COLUMN15_PROMPT	=> L_PROMPT15,
	P_COLUMN16_PROMPT	=> L_PROMPT16,
	P_COLUMN17_PROMPT	=> L_PROMPT17,
	P_COLUMN18_PROMPT	=> L_PROMPT18,
	P_COLUMN19_PROMPT	=> L_PROMPT19,
	P_COLUMN20_PROMPT	=> L_PROMPT20,
	P_COLUMN21_PROMPT	=> L_PROMPT21,
	P_COLUMN22_PROMPT	=> L_PROMPT22,
	P_COLUMN23_PROMPT	=> L_PROMPT23,
	P_COLUMN24_PROMPT	=> L_PROMPT24,
	P_COLUMN25_PROMPT	=> L_PROMPT25,
	P_COLUMN26_PROMPT	=> L_PROMPT26,
	P_COLUMN27_PROMPT	=> L_PROMPT27,
	P_COLUMN28_PROMPT	=> L_PROMPT28,
	P_COLUMN29_PROMPT	=> L_PROMPT29,
	P_COLUMN30_PROMPT	=> L_PROMPT30);

wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt1 '||P_COLUMN1_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt2 '||P_COLUMN2_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt3 '||P_COLUMN3_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt4 '||P_COLUMN4_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt5 '||P_COLUMN5_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt6 '||P_COLUMN6_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt7 '||P_COLUMN7_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt8 '||P_COLUMN8_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt9 '||P_COLUMN9_PROMPT);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_PROMPTS','Prompt10 '||P_COLUMN10_PROMPT);

END GET_DESC_FLEX_ALL_PROMPTS;

-- Bug 4501520 : rvsingh:start

PROCEDURE GET_DESC_FLEX_ALL_VALUES(P_APPLICATION_ID IN VARCHAR2,
						P_DESC_FLEX_DEF_NAME IN  VARCHAR2,
						P_DESC_FLEX_CONTEXT IN VARCHAR2,
						P_COLUMN1_NAME IN VARCHAR2,
						P_COLUMN2_NAME IN VARCHAR2,
						P_COLUMN3_NAME IN VARCHAR2,
						P_COLUMN4_NAME IN VARCHAR2,
						P_COLUMN5_NAME IN VARCHAR2,
						P_COLUMN6_NAME IN VARCHAR2,
						P_COLUMN7_NAME IN VARCHAR2,
						P_COLUMN8_NAME IN VARCHAR2,
						P_COLUMN9_NAME IN VARCHAR2,
						P_COLUMN10_NAME IN VARCHAR2,
						P_COLUMN1_ID_VAL  IN VARCHAR2,
						P_COLUMN2_ID_VAL IN VARCHAR2,
						P_COLUMN3_ID_VAL IN VARCHAR2,
						P_COLUMN4_ID_VAL IN VARCHAR2,
						P_COLUMN5_ID_VAL IN VARCHAR2,
						P_COLUMN6_ID_VAL IN VARCHAR2,
						P_COLUMN7_ID_VAL IN VARCHAR2,
						P_COLUMN8_ID_VAL IN VARCHAR2,
						P_COLUMN9_ID_VAL IN VARCHAR2,
						P_COLUMN10_ID_VAL IN VARCHAR2,
						P_COLUMN1_VAL out nocopy VARCHAR2,
						P_COLUMN2_VAL out nocopy VARCHAR2,
						P_COLUMN3_VAL out nocopy VARCHAR2,
						P_COLUMN4_VAL out nocopy VARCHAR2,
						P_COLUMN5_VAL out nocopy VARCHAR2,
						P_COLUMN6_VAL out nocopy VARCHAR2,
						P_COLUMN7_VAL out nocopy VARCHAR2,
						P_COLUMN8_VAL out nocopy VARCHAR2,
						P_COLUMN9_VAL out nocopy VARCHAR2,
						P_COLUMN10_VAL out nocopy VARCHAR2) AS
	L_VAL11 VARCHAR2(255);
	L_VAL12 VARCHAR2(255);
	L_VAL13 VARCHAR2(255);
	L_VAL14 VARCHAR2(255);
	L_VAL15 VARCHAR2(255);
	L_VAL16 VARCHAR2(255);
	L_VAL17 VARCHAR2(255);
	L_VAL18 VARCHAR2(255);
	L_VAL19 VARCHAR2(255);
	L_VAL20 VARCHAR2(255);
	L_VAL21 VARCHAR2(255);
	L_VAL22 VARCHAR2(255);
	L_VAL23 VARCHAR2(255);
	L_VAL24 VARCHAR2(255);
	L_VAL25 VARCHAR2(255);
	L_VAL26 VARCHAR2(255);
	L_VAL27 VARCHAR2(255);
	L_VAL28 VARCHAR2(255);
	L_VAL29 VARCHAR2(255);
	L_VAL30 VARCHAR2(255);

BEGIN
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','In the GET_DESC_FLEX_ALL_VALUES procedure');

wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL1 '||P_COLUMN1_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL2 '||P_COLUMN2_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL3 '||P_COLUMN3_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL4 '||P_COLUMN4_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL5 '||P_COLUMN5_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL6 '||P_COLUMN6_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL7 '||P_COLUMN7_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL8 '||P_COLUMN8_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL9 '||P_COLUMN9_ID_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','ID_VAL10 '||P_COLUMN10_ID_VAL);

EDR_STANDARD.GET_DESC_FLEX_ALL_VALUES(
	P_APPLICATION_ID        => P_APPLICATION_ID,
	P_DESC_FLEX_DEF_NAME	=> P_DESC_FLEX_DEF_NAME,
	P_DESC_FLEX_CONTEXT	=> P_DESC_FLEX_CONTEXT,
	P_COLUMN1_NAME          => P_COLUMN1_NAME,
	P_COLUMN2_NAME          => P_COLUMN2_NAME,
	P_COLUMN3_NAME          => P_COLUMN3_NAME,
	P_COLUMN4_NAME          => P_COLUMN4_NAME,
	P_COLUMN5_NAME          => P_COLUMN5_NAME,
	P_COLUMN6_NAME          => P_COLUMN6_NAME,
	P_COLUMN7_NAME          => P_COLUMN7_NAME,
	P_COLUMN8_NAME          => P_COLUMN8_NAME,
	P_COLUMN9_NAME          => P_COLUMN9_NAME,
	P_COLUMN10_NAME         => P_COLUMN10_NAME,
	P_COLUMN1_ID_VAL          => P_COLUMN1_ID_VAL,
	P_COLUMN2_ID_VAL          => P_COLUMN2_ID_VAL,
	P_COLUMN3_ID_VAL          => P_COLUMN3_ID_VAL,
	P_COLUMN4_ID_VAL          => P_COLUMN4_ID_VAL,
	P_COLUMN5_ID_VAL          => P_COLUMN5_ID_VAL,
	P_COLUMN6_ID_VAL          => P_COLUMN6_ID_VAL,
	P_COLUMN7_ID_VAL          => P_COLUMN7_ID_VAL,
	P_COLUMN8_ID_VAL          => P_COLUMN8_ID_VAL,
	P_COLUMN9_ID_VAL          => P_COLUMN9_ID_VAL,
	P_COLUMN10_ID_VAL         => P_COLUMN10_ID_VAL,
	P_COLUMN1_VAL        => P_COLUMN1_VAL,
	P_COLUMN2_VAL        => P_COLUMN2_VAL,
	P_COLUMN3_VAL        => P_COLUMN3_VAL,
	P_COLUMN4_VAL        => P_COLUMN4_VAL,
	P_COLUMN5_VAL        => P_COLUMN5_VAL,
	P_COLUMN6_VAL        => P_COLUMN6_VAL,
	P_COLUMN7_VAL        => P_COLUMN7_VAL,
	P_COLUMN8_VAL        => P_COLUMN8_VAL,
	P_COLUMN9_VAL        => P_COLUMN9_VAL,
	P_COLUMN10_VAL 	=> P_COLUMN10_VAL,
	P_COLUMN11_VAL	=> L_VAL11,
	P_COLUMN12_VAL	=> L_VAL12,
	P_COLUMN13_VAL	=> L_VAL13,
	P_COLUMN14_VAL	=> L_VAL14,
	P_COLUMN15_VAL	=> L_VAL15,
	P_COLUMN16_VAL	=> L_VAL16,
	P_COLUMN17_VAL	=> L_VAL17,
	P_COLUMN18_VAL	=> L_VAL18,
	P_COLUMN19_VAL	=> L_VAL19,
	P_COLUMN20_VAL	=> L_VAL20,
	P_COLUMN21_VAL	=> L_VAL21,
	P_COLUMN22_VAL	=> L_VAL22,
	P_COLUMN23_VAL	=> L_VAL23,
	P_COLUMN24_VAL	=> L_VAL24,
	P_COLUMN25_VAL	=> L_VAL25,
	P_COLUMN26_VAL	=> L_VAL26,
	P_COLUMN27_VAL	=> L_VAL27,
	P_COLUMN28_VAL	=> L_VAL28,
	P_COLUMN29_VAL	=> L_VAL29,
	P_COLUMN30_VAL	=> L_VAL30);

wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL1 '||P_COLUMN1_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL2 '||P_COLUMN2_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL3 '||P_COLUMN3_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL4 '||P_COLUMN4_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL5 '||P_COLUMN5_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL6 '||P_COLUMN6_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL7 '||P_COLUMN7_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL8 '||P_COLUMN8_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL9 '||P_COLUMN9_VAL);
wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','VAL10 '||P_COLUMN10_VAL);


END GET_DESC_FLEX_ALL_VALUES;


-- Bug 4501520 : rvsingh:end

PROCEDURE ATTACH_FILE (p_document_id VARCHAR2) AS
  CURSOR GET_TEMP_EREC_ID IS
    select document_id
    from edr_erecord_id_temp;
	l_erecord_id number;

BEGIN
	-- get the erecord id from the temporary table populate by the subscription
	-- rule function before invoking XML Gateway
wf_log_pkg.string(6, 'ATTACH_FILE','Inside Attachment Package, ATTACH_FILE procedure');
               -- Bug 3186732
      -- Issue if XML Map has attachment procedure call then
      -- for those maps user used to get "NO DATA FOUND" Error
      -- because getting eRecord ID from edr_erecord_id_temp
      -- was using SELECT .. INTO .. for utility functions this
      -- row is not present it used give error
      -- modified the select statement and also added a condition
      -- to call copy attachments API only when eRecord ID is present.
      --

      OPEN GET_TEMP_EREC_ID;
      FETCH GET_TEMP_EREC_ID INTO l_erecord_id;

      CLOSE GET_TEMP_EREC_ID;

--	select document_id into l_erecord_id from edr_erecord_id_temp;
wf_log_pkg.string(6, 'ATTACH_FILE','Event ID '||l_erecord_id);
      IF l_eRecord_id is not null THEN
	ATTACH_FILE_AUT(p_document_id, l_erecord_id);
      END IF;
END ATTACH_FILE;

PROCEDURE ATTACH_FILE_AUT (p_document_id VARCHAR2, p_target_value VARCHAR2)
AS PRAGMA AUTONOMOUS_TRANSACTION;
	l_rowid VARCHAR2(100);
	l_atc_doc_id NUMBER;
	l_document_id NUMBER;
	l_user_id NUMBER;
	l_login_id NUMBER;
	l_media_id NUMBER;
	l_language VARCHAR2(10);
BEGIN
	l_document_id := p_document_id;
	wf_log_pkg.string(6, 'ATTACH_FILE_AUT','The FND Document id is '||l_document_id);

	select fnd_attached_documents_s.nextval into l_atc_doc_id
	from dual;

	l_user_id := fnd_global.user_id;
	l_login_id := fnd_global.login_id;

	select userenv('lang') into l_language from dual;

	FND_ATTACHED_DOCUMENTS_PKG.Insert_Row
	(X_Rowid    			=> l_rowid,
	 X_attached_document_id         => l_atc_doc_id,
	 X_document_id                  => l_document_id,
       X_creation_date                => SYSDATE,
	 X_created_by                   => l_user_id,
       X_last_update_date             => SYSDATE,
	 X_last_updated_by              => l_user_id,
	 X_last_update_login            => l_login_id,
	 X_seq_num                      => 1,
	 X_entity_name                  => G_TEMP_ENTITY_NAME,
	 X_column1                      => null,
	 X_pk1_value                    => p_target_value,
	 X_pk2_value                    => null,
	 X_pk3_value                    => null,
	 X_pk4_value                    => null,
	 X_pk5_value                    => null,
       X_automatically_added_flag     => 'N',
       X_datatype_id                  => 6,
	 X_category_id                  => NULL,
	 X_security_type                => NULL,
	 X_publish_flag                 => NULL,
       X_language                     => l_language,
	 X_media_id                     => l_media_id);

commit;
EXCEPTION
	WHEN OTHERS THEN
		wf_log_pkg.string(6, 'ATTACH_FILE_AUT','Unexpected error while writing to FND tables');
		wf_log_pkg.string(6, 'ATTACH_FILE_AUT',SQLERRM);

END ATTACH_FILE_AUT;


--Bug 3893101: Start
FUNCTION PARSE_ATTACHMENT_STRING(P_ATTACHMENT_STRING IN VARCHAR2)
RETURN ERES_ATTACHMENT_TBL_TYPE
is

l_entity_name VARCHAR2(240);
l_pk1_value VARCHAR2(100);
l_pk2_value VARCHAR2(100);
l_pk3_value VARCHAR2(100);
l_pk4_value VARCHAR2(100);
l_pk5_value VARCHAR2(100);
l_category_value VARCHAR2(100);
l_attachment_details_tbl ERES_ATTACHMENT_TBL_TYPE;
l_identified_position NUMBER;
l_temp_count NUMBER;
l_attachment_string VARCHAR2(2000);
l_attachment_string_list FND_TABLE_OF_VARCHAR2_4000;

BEGIN

  l_attachment_string := p_attachment_string;
  --Create a new attachment string list.
  --This would hold each of the attachment strings specified through the input
  --parameter.
  l_attachment_string_list := new FND_TABLE_OF_VARCHAR2_4000();
  l_temp_count := 0;

  l_identified_position := instr(l_attachment_string,'~',1,1);

  --Parse the string and identify the individual attachment strings contained.
  while l_identified_position > 0 loop
    l_temp_count := l_temp_count + 1;
    l_attachment_string_list.extend;
    l_attachment_string_list(l_temp_count) := substr(l_attachment_string,1,l_identified_position-1);
    l_attachment_string := substr(l_attachment_string,l_identified_position+1,length(l_attachment_string)-l_identified_position);
    l_identified_position := instr(l_attachment_string,'~',1,1);
  end loop;

  l_temp_count := l_temp_count + 1;
  l_attachment_string_list.extend;
  l_attachment_string_list(l_temp_count) := l_attachment_string;

  --Parse Each attachment string obtained and get the attachment attributes.
  for i in 1..l_attachment_string_list.count loop
    l_attachment_string := l_attachment_string_list(i);
    l_entity_name:=substr(l_attachment_string,instr(l_attachment_string,'=')+1,
                          instr(l_attachment_string,'&')-(instr(l_attachment_string,'=')+1));

    --This parsing procedure would obtain the attachmewnt attribute values from
    --the attachment string.
    if instr(l_attachment_string,'&',1,3) > 0 then
      l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1,
      instr(l_attachment_string,'&',1,3)-(instr(l_attachment_string,'=',1,3)+1));

      if instr(l_attachment_string,'&',1,5) > 0 then
        l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1,
        instr(l_attachment_string,'&',1,5)-(instr(l_attachment_string,'=',1,5)+1));

        if instr(l_attachment_string,'&',1,7) > 0 then
          l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1,
          instr(l_attachment_string,'&',1,7)-(instr(l_attachment_string,'=',1,7)+1));

          if instr(l_attachment_string,'&',1,9) > 0 then
            l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1,
            instr(l_attachment_string,'&',1,9)-(instr(l_attachment_string,'=',1,9)+1));

            if instr(l_attachment_string,'&',1,11) > 0 then
              l_pk5_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1,
              instr(l_attachment_string,'&',1,11)-(instr(l_attachment_string,'=',1,11)+1));

              if instr(l_attachment_string,'=',1,12) > 0 then
                l_category_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,12)+1);
              end if;
            else

              if(instr(l_attachment_string,'&',1,10) > 0 and instr(l_attachment_string,'=',1,11) >0) then
                l_pk5_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,11)+1);
              elsif(instr(l_attachment_string,'&',1,9) > 0 and instr(l_attachment_string,'=',1,10) > 0) then
                l_category_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,10)+1);
              end if;
            end if;
          else
            if(instr(l_attachment_string,'&',1,8) > 0 and instr(l_attachment_string,'=',1,9) >0) then
              l_pk4_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,9)+1);

  		      elsif(instr(l_attachment_string,'&',1,7) > 0 and instr(l_attachment_string,'=',1,8) > 0) then
        			l_category_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,8)+1);

            end if;
          end if;

        else

          if(instr(l_attachment_string,'&',1,6) > 0 and instr(l_attachment_string,'=',1,7) >0) then
            l_pk3_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,7)+1);

          elsif(instr(l_attachment_string,'&',1,5) > 0 and instr(l_attachment_string,'=',1,6) > 0) then
            l_category_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,6)+1);
          end if;
        end if;

      else
        if(instr(l_attachment_string,'&',1,4) > 0 and instr(l_attachment_string,'=',1,5) >0) then
          l_pk2_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,5)+1);

        elsif(instr(l_attachment_string,'&',1,3) > 0 and instr(l_attachment_string,'=',1,4) > 0) then
          l_category_value := substr(l_attachment_string,instr(l_attachment_string,'=',1,4)+1);
        end if;
      end if;

    else
      l_pk1_value:= substr(l_attachment_string,instr(l_attachment_string,'=',1,3)+1);
    END IF;

    --Set the attachment attribute values.
    l_attachment_details_tbl(i).ENTITY_NAME := l_entity_name;
    l_attachment_details_tbl(i).PK1_VALUE := l_pk1_value;
    l_attachment_details_tbl(i).PK2_VALUE := l_pk2_value;
    l_attachment_details_tbl(i).PK3_VALUE := l_pk3_value;
    l_attachment_details_tbl(i).PK4_VALUE := l_pk4_value;
    l_attachment_details_tbl(i).PK5_VALUE := l_pk5_value;
    l_attachment_details_tbl(i).CATEGORY := l_category_value;
  END LOOP;
  --Return this table of attachment details
  return l_attachment_details_tbl;

  EXCEPTION
    when others then
      null;

END PARSE_ATTACHMENT_STRING;

--This method would be used to add an ERP attachment for each of the
--attachment strings specified in the input parameter.
PROCEDURE ADD_ERP_ATTACH(P_ATTACHMENT_STRING IN VARCHAR2)
is

l_attachment_details_tbl ERES_ATTACHMENT_TBL_TYPE;

BEGIN

  --Obtain the details of the attachment string in a table of attachment
  --attributes.
  l_attachment_details_tbl := PARSE_ATTACHMENT_STRING(P_ATTACHMENT_STRING);

  if l_attachment_details_tbl is not null and l_attachment_details_tbl.count > 0 then
    for i in 1..l_attachment_details_tbl.count loop
      --Call the attachment API for each attachment attribute details found.
      ATTACH_ERP (p_entity_name => l_attachment_details_tbl(i).ENTITY_NAME,
                  p_pk1_value => l_attachment_details_tbl(i).PK1_VALUE,
            	    p_pk2_value => l_attachment_details_tbl(i).PK2_VALUE,
        			    p_pk3_value => l_attachment_details_tbl(i).PK3_VALUE,
            	    p_pk4_value => l_attachment_details_tbl(i).PK4_VALUE,
             	    p_pk5_value => l_attachment_details_tbl(i).PK5_VALUE,
        			    p_category => l_attachment_details_tbl(i).CATEGORY
                 );
    end loop;
  end if;


  exception
    when others then
      null;

END ADD_ERP_ATTACH;
--Bug 3893101: End

END EDR_ATTACHMENTS_GRP;

/
