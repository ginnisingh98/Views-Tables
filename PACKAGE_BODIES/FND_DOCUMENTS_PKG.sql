--------------------------------------------------------
--  DDL for Package Body FND_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DOCUMENTS_PKG" as
/* $Header: AFAKADCB.pls 120.4.12010000.2 2010/02/16 22:14:42 ctilley ship $ */



PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_document_id                  IN OUT NOCOPY NUMBER,
                     X_creation_date                DATE,
                     X_created_by                   NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER DEFAULT NULL,
                     X_datatype_id                  NUMBER,
                     X_category_id                  NUMBER,
                     X_security_type                NUMBER,
                     X_security_id                  NUMBER DEFAULT NULL,
                     X_publish_flag                 VARCHAR2,
                     X_image_type                   VARCHAR2 DEFAULT NULL,
                     X_storage_type                 NUMBER DEFAULT NULL,
                     X_usage_type                VARCHAR2,
                     X_start_date_active            DATE DEFAULT NULL,
                     X_end_date_active              DATE DEFAULT NULL,
                     X_request_id                   NUMBER DEFAULT NULL,
                     X_program_application_id       NUMBER DEFAULT NULL,
                     X_program_id                   NUMBER DEFAULT NULL,
                     X_program_update_date          DATE DEFAULT NULL,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2 DEFAULT NULL,
                     X_file_name                    VARCHAR2 DEFAULT NULL,
                     X_media_id                     IN OUT NOCOPY NUMBER,
                  X_Attribute_Category              VARCHAR2 DEFAULT NULL,
                  X_Attribute1                      VARCHAR2 DEFAULT NULL,
                  X_Attribute2                      VARCHAR2 DEFAULT NULL,
                  X_Attribute3                      VARCHAR2 DEFAULT NULL,
                  X_Attribute4                      VARCHAR2 DEFAULT NULL,
                  X_Attribute5                      VARCHAR2 DEFAULT NULL,
                  X_Attribute6                      VARCHAR2 DEFAULT NULL,
                  X_Attribute7                      VARCHAR2 DEFAULT NULL,
                  X_Attribute8                      VARCHAR2 DEFAULT NULL,
                  X_Attribute9                      VARCHAR2 DEFAULT NULL,
                  X_Attribute10                     VARCHAR2 DEFAULT NULL,
                  X_Attribute11                     VARCHAR2 DEFAULT NULL,
                  X_Attribute12                     VARCHAR2 DEFAULT NULL,
                  X_Attribute13                     VARCHAR2 DEFAULT NULL,
                  X_Attribute14                     VARCHAR2 DEFAULT NULL,
                  X_Attribute15                     VARCHAR2 DEFAULT NULL,
		  X_create_doc                      VARCHAR2 DEFAULT 'N',
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid
                 FROM fnd_documents
                WHERE document_id = X_document_id;

 l_media_id number;
 l_longtxt varchar2(32767);
 l_app_s_v varchar2(255);

BEGIN

l_media_id := X_media_id;

  --  Get document_id from sequence
  SELECT fnd_documents_s.nextval
    INTO X_document_id
    FROM dual;


  --  Get media_id from the correct sequence depending on if it's
  --  a short-text, long-text, ole_object, or db-stored image

  IF (X_datatype_id = 1) THEN
	SELECT fnd_documents_short_text_s.nextval
	  INTO X_media_id
	  FROM dual;
    IF (X_create_doc = 'Y') then
     insert into fnd_documents_short_text
        (media_id, short_text, app_source_version)
        select X_media_id, short_text, app_source_version
        from fnd_documents_short_text
        where media_id = l_media_id;

    END IF;
  ELSIF (X_datatype_id = 2) THEN
     SELECT fnd_documents_long_text_s.nextval
       INTO X_media_id
       FROM dual;
   IF (X_create_doc = 'Y') then
      select long_text,app_source_version into l_longtxt,l_app_s_v from fnd_documents_long_text
      where media_id = l_media_id;
     insert into fnd_documents_long_text
     (media_id,long_text,app_source_version)
     values (X_media_id,l_longtxt,l_app_s_v);
   END IF;
  ELSIF (  (X_datatype_id = 4)
         OR ( X_datatype_id = 3
             AND X_storage_type = 1) ) THEN
      SELECT fnd_documents_long_raw_s.nextval
        INTO X_media_id
        FROM dual;
  ELSIF (X_datatype_id = 6 and X_media_id is NULL) THEN
    SELECT fnd_lobs_s.nextval
      INTO X_media_id
      FROM dual;
  END IF;

  --  First insert row into "base" table
  INSERT INTO fnd_documents(
	 document_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 datatype_id,
	 category_id,
	 security_type,
	 security_id,
	 publish_flag,
	 image_type,
	 storage_type,
	 usage_type,
	 start_date_active,
	 end_date_active,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date,
         url,
         media_id,
         file_name,
         dm_node,
         dm_folder_path,
         dm_type,
         dm_document_id,
         dm_version_number) VALUES (
	 X_document_id,
	 X_creation_date,
	 X_created_by,
	 X_last_update_date,
	 X_last_updated_by,
	 X_last_update_login,
	 X_datatype_id,
	 X_category_id,
	 X_security_type,
	 X_security_id,
	 X_publish_flag,
	 X_image_type,
	 X_storage_type,
	 X_usage_type,
	 X_start_date_active,
	 X_end_date_active,
	 X_request_id,
	 X_program_application_id,
	 X_program_id,
	 X_program_update_date,
	 X_url,
         X_media_id,
	 X_file_name,
         X_dm_node,
         X_dm_folder_path,
         X_dm_type,
         X_dm_document_id,
         X_dm_version_number);

 --  Next call procedure to put row into
 --  "language" table that has normalized language-specific
 --  columns
 insert_tl_row(X_document_id => X_document_id,
	 X_creation_date     => X_creation_date,
	 X_created_by        => X_created_by,
	 X_last_update_date  => X_last_update_date,
	 X_last_updated_by   => X_last_updated_by,
	 X_last_update_login => X_last_update_login,
	 X_language          => X_language,
	 X_description       => X_description,
	 X_request_id        => X_request_id,
	 X_program_application_id => X_program_application_id,
	 X_program_id        => X_program_id,
	 X_program_update_date => X_program_update_date,
	 X_attribute_category  => X_attribute_category,
	 X_attribute1          => X_attribute1,
	 X_attribute2          => X_attribute2,
	 X_attribute3          => X_attribute3,
	 X_attribute4          => X_attribute4,
	 X_attribute5          => X_attribute5,
	 X_attribute6          => X_attribute6,
	 X_attribute7          => X_attribute7,
	 X_attribute8          => X_attribute8,
	 X_attribute9          => X_attribute9,
	 X_attribute10         => X_attribute10,
	 X_attribute11         => X_attribute11,
	 X_attribute12         => X_attribute12,
	 X_attribute13         => X_attribute13,
	 X_attribute14         => X_attribute14,
	 X_attribute15         => X_attribute15,
         X_title	       => X_title);

  --  get rowid to pass back to form
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;

    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;


PROCEDURE insert_tl_row(X_document_id               NUMBER,
                     X_creation_date                DATE,
                     X_created_by                   NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER DEFAULT NULL,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2 DEFAULT NULL,
                     X_request_id                   NUMBER DEFAULT NULL,
                     X_program_application_id       NUMBER DEFAULT NULL,
                     X_program_id                   NUMBER DEFAULT NULL,
                     X_program_update_date          DATE DEFAULT NULL,
                  X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                  X_Attribute1                          VARCHAR2 DEFAULT NULL,
                  X_Attribute2                          VARCHAR2 DEFAULT NULL,
                  X_Attribute3                          VARCHAR2 DEFAULT NULL,
                  X_Attribute4                          VARCHAR2 DEFAULT NULL,
                  X_Attribute5                          VARCHAR2 DEFAULT NULL,
                  X_Attribute6                          VARCHAR2 DEFAULT NULL,
                  X_Attribute7                          VARCHAR2 DEFAULT NULL,
                  X_Attribute8                          VARCHAR2 DEFAULT NULL,
                  X_Attribute9                          VARCHAR2 DEFAULT NULL,
                  X_Attribute10                         VARCHAR2 DEFAULT NULL,
                  X_Attribute11                         VARCHAR2 DEFAULT NULL,
                  X_Attribute12                         VARCHAR2 DEFAULT NULL,
                  X_Attribute13                         VARCHAR2 DEFAULT NULL,
                  X_Attribute14                         VARCHAR2 DEFAULT NULL,
                  X_Attribute15                         VARCHAR2 DEFAULT NULL,
                  X_title				VARCHAR2 DEFAULT NULL)
 IS
BEGIN

  --  insert into "language" specific table
  INSERT INTO fnd_Documents_tl (
	 document_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 description,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date,
	 doc_attribute_category,
	 doc_attribute1,
	 doc_attribute2,
	 doc_attribute3,
	 doc_attribute4,
	 doc_attribute5,
	 doc_attribute6,
	 doc_attribute7,
	 doc_attribute8,
	 doc_attribute9,
	 doc_attribute10,
	 doc_attribute11,
	 doc_attribute12,
	 doc_attribute13,
	 doc_attribute14,
	 doc_attribute15,
         source_lang,
         title) SELECT
	 X_document_id,
	 X_creation_date,
	 X_created_by,
	 X_last_update_date,
	 X_last_updated_by,
	 X_last_update_login,
	 L.language_code,
	 X_description,
	 X_request_id,
	 X_program_application_id,
	 X_program_id,
	 X_program_update_date,
	 X_attribute_category,
	 X_attribute1,
	 X_attribute2,
	 X_attribute3,
	 X_attribute4,
	 X_attribute5,
	 X_attribute6,
	 X_attribute7,
	 X_attribute8,
	 X_attribute9,
	 X_attribute10,
	 X_attribute11,
	 X_attribute12,
	 X_attribute13,
	 X_attribute14,
	 X_attribute15,
	 userenv('LANG'),
         X_title
    FROM fnd_languages L
   WHERE l.installed_flag IN ('I','B')
     AND NOT EXISTS (SELECT null
		       FROM fnd_documents_tl TL
		      WHERE document_id = x_document_id
		        AND TL.language = l.language_code);

END Insert_tl_Row;



PROCEDURE Lock_Row(X_document_id                  NUMBER,
                     X_datatype_id                  NUMBER,
                     X_category_id                  NUMBER,
                     X_security_type                NUMBER,
                     X_security_id                  NUMBER DEFAULT NULL,
                     X_publish_flag                 VARCHAR2,
                     X_image_type                   VARCHAR2 DEFAULT NULL,
                     X_storage_type                 NUMBER DEFAULT NULL,
                     X_usage_type                VARCHAR2,
                     X_start_date_active            DATE DEFAULT NULL,
                     X_end_date_active              DATE DEFAULT NULL,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2 DEFAULT NULL,
                     X_file_name                    VARCHAR2 DEFAULT NULL,
                     X_media_id                     NUMBER,
                X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                X_Attribute1                            VARCHAR2 DEFAULT NULL,
                X_Attribute2                            VARCHAR2 DEFAULT NULL,
                X_Attribute3                            VARCHAR2 DEFAULT NULL,
                X_Attribute4                            VARCHAR2 DEFAULT NULL,
                X_Attribute5                            VARCHAR2 DEFAULT NULL,
                X_Attribute6                            VARCHAR2 DEFAULT NULL,
                X_Attribute7                            VARCHAR2 DEFAULT NULL,
                X_Attribute8                            VARCHAR2 DEFAULT NULL,
                X_Attribute9                            VARCHAR2 DEFAULT NULL,
                X_Attribute10                           VARCHAR2 DEFAULT NULL,
                X_Attribute11                           VARCHAR2 DEFAULT NULL,
                X_Attribute12                           VARCHAR2 DEFAULT NULL,
                X_Attribute13                           VARCHAR2 DEFAULT NULL,
                X_Attribute14                           VARCHAR2 DEFAULT NULL,
                X_Attribute15                           VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL) IS
  CURSOR C IS
      SELECT *
      FROM   fnd_documents
      WHERE  document_id = X_document_id
      FOR UPDATE of document_id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  if (
          (   (Recinfo.document_id = X_document_id) )
      AND (   (Recinfo.datatype_id = X_datatype_id) )
      AND (   (Recinfo.category_id = X_category_Id) )
      AND (   (Recinfo.security_type = X_security_type) )
      AND (   (Recinfo.security_id = X_security_id)
           OR (    (Recinfo.security_id IS NULL)
               AND (X_security_id IS NULL)))
      AND (   (Recinfo.publish_flag = X_publish_flag) )
      AND (   (Recinfo.image_type = X_image_type)
           OR (    (Recinfo.image_type IS NULL)
               AND (X_image_type IS NULL)))
      AND (   (Recinfo.storage_type = X_storage_type)
           OR (    (Recinfo.storage_type IS NULL)
               AND (X_storage_type IS NULL)))
      AND (   (Recinfo.usage_type = X_usage_type)
           OR (    (Recinfo.usage_type IS NULL)
               AND (X_usage_type IS NULL)))
      AND (   (Recinfo.start_date_active = X_start_date_active)
           OR (    (Recinfo.start_date_active IS NULL)
               AND (X_start_date_active IS NULL)))
      AND (   (Recinfo.end_date_active = X_end_date_active)
           OR (    (Recinfo.end_date_active IS NULL)
               AND (X_end_date_active IS NULL)))
      AND (   (Recinfo.file_name = X_file_name)
           OR (    (Recinfo.file_name IS NULL)
               AND (X_file_name IS NULL)))
      AND (   (Recinfo.media_id = X_media_id)
           OR (    (Recinfo.media_id IS NULL)
               AND (X_media_id IS NULL)))
      AND (   (Recinfo.url = X_url)
           OR (    (Recinfo.url IS NULL)
               AND (X_url IS NULL)))
          ) then

    lock_tl_row(X_document_id             => X_document_id,
                X_language                => X_language,
                X_description             => X_description,
                X_Attribute_Category      => X_Attribute_Category,
                X_Attribute1              => X_Attribute1,
                X_Attribute2              => X_Attribute2,
                X_Attribute3              => X_Attribute3,
                X_Attribute4              => X_Attribute4,
                X_Attribute5              => X_Attribute5,
                X_Attribute6              => X_Attribute6,
                X_Attribute7              => X_Attribute7,
                X_Attribute8              => X_Attribute8,
                X_Attribute9              => X_Attribute9,
                X_Attribute10             => X_Attribute10,
                X_Attribute11             => X_Attribute11,
                X_Attribute12             => X_Attribute12,
                X_Attribute13             => X_Attribute13,
                X_Attribute14             => X_Attribute14,
                X_Attribute15             => X_Attribute15,
                X_title                   => X_title);

    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Lock_tl_Row(X_document_id                  NUMBER,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2,
                X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                X_Attribute1                            VARCHAR2 DEFAULT NULL,
                X_Attribute2                            VARCHAR2 DEFAULT NULL,
                X_Attribute3                            VARCHAR2 DEFAULT NULL,
                X_Attribute4                            VARCHAR2 DEFAULT NULL,
                X_Attribute5                            VARCHAR2 DEFAULT NULL,
                X_Attribute6                            VARCHAR2 DEFAULT NULL,
                X_Attribute7                            VARCHAR2 DEFAULT NULL,
                X_Attribute8                            VARCHAR2 DEFAULT NULL,
                X_Attribute9                            VARCHAR2 DEFAULT NULL,
                X_Attribute10                           VARCHAR2 DEFAULT NULL,
                X_Attribute11                           VARCHAR2 DEFAULT NULL,
                X_Attribute12                           VARCHAR2 DEFAULT NULL,
                X_Attribute13                           VARCHAR2 DEFAULT NULL,
                X_Attribute14                           VARCHAR2 DEFAULT NULL,
                X_Attribute15                           VARCHAR2 DEFAULT NULL,
                X_title                                 VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   fnd_documents_tl
      WHERE  document_id = X_document_id
        AND  language = X_language
      FOR UPDATE of language NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  if (
          (   (Recinfo.document_id = X_document_id) )
      AND (   (Recinfo.language = X_language) )
      AND (   (Recinfo.description = X_description)
           OR (    (Recinfo.description IS NULL)
               AND (X_description IS NULL)))
      AND (   (Recinfo.doc_attribute_category = X_Attribute_Category)
           OR (    (Recinfo.doc_attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.doc_attribute1 = X_Attribute1)
           OR (    (Recinfo.doc_attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.doc_attribute2 = X_Attribute2)
           OR (    (Recinfo.doc_attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.doc_attribute3 = X_Attribute3)
           OR (    (Recinfo.doc_attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.doc_attribute4 = X_Attribute4)
           OR (    (Recinfo.doc_attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.doc_attribute5 = X_Attribute5)
           OR (    (Recinfo.doc_attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.doc_attribute6 = X_Attribute6)
           OR (    (Recinfo.doc_attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.doc_attribute7 = X_Attribute7)
           OR (    (Recinfo.doc_attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.doc_attribute8 = X_Attribute8)
           OR (    (Recinfo.doc_attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.doc_attribute9 = X_Attribute9)
           OR (    (Recinfo.doc_attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.doc_attribute10 = X_Attribute10)
           OR (    (Recinfo.doc_attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.doc_attribute11 = X_Attribute11)
           OR (    (Recinfo.doc_attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.doc_attribute12 = X_Attribute12)
           OR (    (Recinfo.doc_attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.doc_attribute13 = X_Attribute13)
           OR (    (Recinfo.doc_attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.doc_attribute14 = X_Attribute14)
           OR (    (Recinfo.doc_attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.doc_attribute15 = X_Attribute15)
           OR (    (Recinfo.doc_attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.title = X_title)
           OR (    (Recinfo.title IS NULL)
               AND (X_title IS NULL)))
          ) then
    return;
  else

    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_tl_Row;


PROCEDURE Update_Row(X_document_id                  NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER,
                     X_datatype_id                  NUMBER,
                     X_category_id                  NUMBER,
                     X_security_type                NUMBER,
                     X_security_id                  NUMBER,
                     X_publish_flag                 VARCHAR2,
                     X_image_type                   VARCHAR2,
                     X_storage_type                 NUMBER,
                     X_usage_type                VARCHAR2,
                     X_start_date_active            DATE,
                     X_end_date_active              DATE,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2,
                     X_file_name                    VARCHAR2,
                     X_media_id                     NUMBER,
                  X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                  X_Attribute1                          VARCHAR2 DEFAULT NULL,
                  X_Attribute2                          VARCHAR2 DEFAULT NULL,
                  X_Attribute3                          VARCHAR2 DEFAULT NULL,
                  X_Attribute4                          VARCHAR2 DEFAULT NULL,
                  X_Attribute5                          VARCHAR2 DEFAULT NULL,
                  X_Attribute6                          VARCHAR2 DEFAULT NULL,
                  X_Attribute7                          VARCHAR2 DEFAULT NULL,
                  X_Attribute8                          VARCHAR2 DEFAULT NULL,
                  X_Attribute9                          VARCHAR2 DEFAULT NULL,
                  X_Attribute10                         VARCHAR2 DEFAULT NULL,
                  X_Attribute11                         VARCHAR2 DEFAULT NULL,
                  X_Attribute12                         VARCHAR2 DEFAULT NULL,
                  X_Attribute13                         VARCHAR2 DEFAULT NULL,
                  X_Attribute14                         VARCHAR2 DEFAULT NULL,
                  X_Attribute15                         VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL
) IS
BEGIN
  UPDATE fnd_documents
  SET document_id = X_document_id,
      last_update_date = X_last_update_date,
	 last_updated_by = X_last_updated_by,
	 last_update_login = X_last_update_login,
	 datatype_id = X_datatype_id,
	 category_id = X_category_id,
	 security_type = X_security_type,
	 security_id = X_security_id,
	 publish_flag = X_publish_flag,
	 image_type = X_image_type,
	 storage_type = X_storage_type,
	 usage_type = X_usage_type,
	 start_date_active = X_start_date_Active,
	 end_date_active = X_end_date_Active,
         url = X_url,
         media_id = X_media_id,
         file_name = X_file_name,
         dm_node = X_dm_node,
         dm_folder_path = X_dm_folder_path,
         dm_type = X_dm_type,
         dm_document_id = X_dm_document_id,
         dm_version_number = X_dm_version_number
  WHERE document_id  = X_document_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

 --  now update language-specific row
 Update_tl_Row(X_document_id             => X_document_id,
               X_last_update_date        => X_last_update_date,
               X_last_updated_by         => X_last_updated_by,
               X_last_update_login       => X_last_update_login,
               X_language                => X_language,
               X_description             => X_description,
               X_Attribute_Category      => X_Attribute_Category,
               X_Attribute1              => X_Attribute1,
               X_Attribute2              => X_Attribute2,
               X_Attribute3              => X_Attribute3,
               X_Attribute4              => X_Attribute4,
               X_Attribute5              => X_Attribute5,
               X_Attribute6              => X_Attribute6,
               X_Attribute7              => X_Attribute7,
               X_Attribute8              => X_Attribute8,
               X_Attribute9              => X_Attribute9,
               X_Attribute10             => X_Attribute10,
               X_Attribute11             => X_Attribute11,
               X_Attribute12             => X_Attribute12,
               X_Attribute13             => X_Attribute13,
               X_Attribute14             => X_Attribute14,
               X_Attribute15             => X_Attribute15,
               X_title                   => X_title);


END Update_Row;


PROCEDURE Update_tl_Row(X_document_id                  NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER DEFAULT NULL,
                     X_language                     VARCHAR2,
                     X_description                  VARCHAR2 DEFAULT NULL,
                  X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                  X_Attribute1                          VARCHAR2 DEFAULT NULL,
                  X_Attribute2                          VARCHAR2 DEFAULT NULL,
                  X_Attribute3                          VARCHAR2 DEFAULT NULL,
                  X_Attribute4                          VARCHAR2 DEFAULT NULL,
                  X_Attribute5                          VARCHAR2 DEFAULT NULL,
                  X_Attribute6                          VARCHAR2 DEFAULT NULL,
                  X_Attribute7                          VARCHAR2 DEFAULT NULL,
                  X_Attribute8                          VARCHAR2 DEFAULT NULL,
                  X_Attribute9                          VARCHAR2 DEFAULT NULL,
                  X_Attribute10                         VARCHAR2 DEFAULT NULL,
                  X_Attribute11                         VARCHAR2 DEFAULT NULL,
                  X_Attribute12                         VARCHAR2 DEFAULT NULL,
                  X_Attribute13                         VARCHAR2 DEFAULT NULL,
                  X_Attribute14                         VARCHAR2 DEFAULT NULL,
                  X_Attribute15                         VARCHAR2 DEFAULT NULL,
                  X_title				VARCHAR2 DEFAULT NULL
) IS
BEGIN
  UPDATE fnd_documents_tl
  SET document_id = X_document_id,
      last_update_date = X_last_update_date,
      last_updated_by =  X_last_updated_by,
      last_update_login = X_last_update_login,
      language = X_language,
      description = X_description,
      doc_attribute_category = X_Attribute_Category,
      doc_attribute1 = X_Attribute1,
      doc_attribute2 =  X_Attribute2,
      doc_attribute3 =  X_Attribute3,
      doc_attribute4 =  X_Attribute4,
      doc_attribute5 =  X_Attribute5,
      doc_attribute6 =  X_Attribute6,
      doc_attribute7 =  X_Attribute7,
      doc_attribute8 =  X_Attribute8,
      doc_attribute9 =  X_Attribute9,
      doc_attribute10 = X_Attribute10,
      doc_attribute11 = X_Attribute11,
      doc_attribute12 = X_Attribute12,
      doc_attribute13 = X_Attribute13,
      doc_attribute14 = X_Attribute14,
      doc_attribute15 = X_Attribute15,
      title = X_title
  WHERE document_id = X_document_id
    AND language = X_language;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_tl_Row;

PROCEDURE Delete_Row(X_document_id NUMBER,
	             X_datatype_id NUMBER,
		     delete_ref_Flag VARCHAR2 DEFAULT 'N') IS
BEGIN
  --  need to delete in this order for R10-10SC compatibility
  --  triggers to operate properly
  --  1.  fnd_attached_documents
  --  2.  fnd_documents_short_text/long_text/long_raw
  --  3.  fnd_documents_tl
  --  4.  fnd_documents
 -- Delete the Reference if flag set to Y
 IF (delete_ref_flag = 'Y') THEN
	DELETE FROM fnd_attached_documents
	WHERE document_id = X_document_id;
 END IF;

  --  now go about the business of deleting the document from
  --  the document tables
  IF (X_datatype_id = 1) THEN
	  DELETE FROM fnd_documents_short_text
   	WHERE media_id IN
		(SELECT media_id
	 	 FROM fnd_documents
		 WHERE document_id = x_document_id);
  ELSIF (X_datatype_id = 2) THEN
	  DELETE FROM fnd_documents_long_text
   	   WHERE media_id IN
		(SELECT media_id
		  FROM fnd_documents
		  WHERE document_id = x_document_id);
   ELSIF (X_datatype_id IN (3,4) ) THEN
	  DELETE FROM fnd_documents_long_raw
   	   WHERE media_id IN
		(SELECT media_id
		  FROM fnd_documents
		  WHERE document_id = x_document_id);
   ELSIF (X_datatype_id = 6) THEN
         DELETE FROM fnd_lobs
         WHERE file_id in
               (SELECT media_id
                from fnd_documents
                WHERE document_id = x_document_id);
   END IF;

 DELETE FROM fnd_documents_tl
   WHERE document_id = X_document_id;

 DELETE FROM fnd_documents
  WHERE document_id = X_document_id;

END Delete_Row;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_DOCUMENTS_TL T
  where not exists
    (select NULL
    from FND_DOCUMENTS B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    );

  update FND_DOCUMENTS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FND_DOCUMENTS_TL B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ID,
      SUBT.LANGUAGE
    from FND_DOCUMENTS_TL SUBB, FND_DOCUMENTS_TL SUBT
    where SUBB.DOCUMENT_ID = SUBT.DOCUMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

   insert /*+ append parallel(tt) */ into FND_DOCUMENTS_TL tt (
    DOCUMENT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    DOC_ATTRIBUTE_CATEGORY,
    DOC_ATTRIBUTE1,
    DOC_ATTRIBUTE2,
    DOC_ATTRIBUTE3,
    DOC_ATTRIBUTE4,
    DOC_ATTRIBUTE5,
    DOC_ATTRIBUTE6,
    DOC_ATTRIBUTE7,
    DOC_ATTRIBUTE8,
    DOC_ATTRIBUTE9,
    DOC_ATTRIBUTE10,
    DOC_ATTRIBUTE11,
    DOC_ATTRIBUTE12,
    DOC_ATTRIBUTE13,
    DOC_ATTRIBUTE14,
    DOC_ATTRIBUTE15,
    APP_SOURCE_VERSION,
    SHORT_TEXT,
    LANGUAGE,
    SOURCE_LANG)
    select /*+ parallel(v) parallel(t) use_nl(t) */  v.*
    from( SELECT /*+ no_merge ordered parellel(b) */
    B.DOCUMENT_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    B.DOC_ATTRIBUTE_CATEGORY,
    B.DOC_ATTRIBUTE1,
    B.DOC_ATTRIBUTE2,
    B.DOC_ATTRIBUTE3,
    B.DOC_ATTRIBUTE4,
    B.DOC_ATTRIBUTE5,
    B.DOC_ATTRIBUTE6,
    B.DOC_ATTRIBUTE7,
    B.DOC_ATTRIBUTE8,
    B.DOC_ATTRIBUTE9,
    B.DOC_ATTRIBUTE10,
    B.DOC_ATTRIBUTE11,
    B.DOC_ATTRIBUTE12,
    B.DOC_ATTRIBUTE13,
    B.DOC_ATTRIBUTE14,
    B.DOC_ATTRIBUTE15,
    B.APP_SOURCE_VERSION,
    B.SHORT_TEXT,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_DOCUMENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  ) v, fnd_documents_tl t
    where T.DOCUMENT_ID(+) = v.DOCUMENT_ID
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
    and t.document_id IS NULL;

end ADD_LANGUAGE;

END fnd_documents_pkg;

/
