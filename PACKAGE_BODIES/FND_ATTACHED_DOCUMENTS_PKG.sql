--------------------------------------------------------
--  DDL for Package Body FND_ATTACHED_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ATTACHED_DOCUMENTS_PKG" as
/* $Header: AFAKAADB.pls 120.3.12010000.3 2010/08/31 16:06:34 ctilley ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_attached_document_id         IN OUT NOCOPY NUMBER,
                     X_document_id                  IN OUT NOCOPY NUMBER,
                     X_creation_date                DATE,
                     X_created_by                   NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER DEFAULT NULL,
                     X_seq_num                      NUMBER,
                     X_entity_name                  VARCHAR2,
                     X_column1                      VARCHAR2,
                     X_pk1_value                    VARCHAR2,
                     X_pk2_value                    VARCHAR2,
                     X_pk3_value                    VARCHAR2,
                     X_pk4_value                    VARCHAR2,
                     X_pk5_value                    VARCHAR2,
                  X_automatically_added_flag     VARCHAR2,
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
                  /*  columns necessary for creating a document on the fly */
                  X_datatype_id                  NUMBER,
                  X_category_id                  NUMBER,
                  X_security_type                NUMBER,
                  X_security_id                  NUMBER DEFAULT NULL,
                  X_publish_flag                 VARCHAR2,
                  X_image_type                   VARCHAR2 DEFAULT NULL,
                  X_storage_type                 NUMBER DEFAULT NULL,
                  X_usage_type                   VARCHAR2,
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
		  X_doc_attribute_Category       VARCHAR2,
	          X_doc_attribute1               VARCHAR2,
	          X_doc_attribute2               VARCHAR2,
	          X_doc_attribute3               VARCHAR2,
	          X_doc_attribute4               VARCHAR2,
	          X_doc_attribute5               VARCHAR2,
	          X_doc_attribute6               VARCHAR2,
	          X_doc_attribute7               VARCHAR2,
	          X_doc_attribute8               VARCHAR2,
	          X_doc_attribute9               VARCHAR2,
	          X_doc_attribute10              VARCHAR2,
	          X_doc_attribute11              VARCHAR2,
	          X_doc_attribute12              VARCHAR2,
	          X_doc_attribute13              VARCHAR2,
	          X_doc_attribute14              VARCHAR2,
	          X_doc_attribute15              VARCHAR2,
                  X_create_doc                   VARCHAR2 DEFAULT 'N',
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL) IS

  tmp_rowid VARCHAR2(30);


   CURSOR C IS SELECT rowid
                 FROM fnd_attached_documents
                WHERE attached_document_id = X_attached_document_id;

  l_usage_type varchar2(1);
  l_create_doc varchar2(1);


BEGIN

  --  Create document if necessary (indicated by X_document_id being
  --  null)
  IF (X_document_id IS NULL) THEN

    if (x_usage_type = 'T') then
          l_usage_type := 'O';
          l_create_doc := 'Y';
      else
          l_usage_type := x_usage_type;
          l_create_doc := x_create_doc;
      end if;


    fnd_documents_pkg.insert_row(
            X_rowid               => tmp_rowid,
            X_document_id         => X_document_id,
            X_creation_date       => X_creation_date,
            X_created_by          => X_created_by,
            X_last_update_date    => X_last_update_date,
            X_last_updated_by     => X_last_updated_by,
            X_last_update_login   => X_last_update_login,
            X_datatype_id         => X_datatype_id,
            X_category_id         => X_category_id,
            X_security_type       => X_security_type,
            X_security_id         => X_security_id,
           X_publish_flag         => X_publish_flag,
           X_image_type           => X_image_type,
           X_storage_type         => X_storage_type,
           X_usage_type           => NVL(l_usage_type,'O'),
           X_start_date_active    =>  null,
           X_end_date_active      =>  null,
           X_request_id           => X_request_id,
           X_program_application_id => X_program_application_id,
           X_program_id           => X_program_id,
           X_program_update_date  => X_program_update_date,
           X_language             => X_language,
           X_description          => X_description,
           X_file_name            => X_file_name,
           X_media_id             => X_media_id,
	   X_attribute_category   => X_doc_attribute_category,
	   X_attribute1           => X_doc_attribute1,
	   X_attribute2           => X_doc_attribute2,
	   X_attribute3           => X_doc_attribute3,
	   X_attribute4           => X_doc_attribute4,
	   X_attribute5           => X_doc_attribute5,
	   X_attribute6           => X_doc_attribute6,
	   X_attribute7           => X_doc_attribute7,
	   X_attribute8           => X_doc_attribute8,
	   X_attribute9           => X_doc_attribute9,
	   X_attribute10          => X_doc_attribute10,
	   X_attribute11          => X_doc_attribute11,
	   X_attribute12          => X_doc_attribute12,
	   X_attribute13          => X_doc_attribute13,
	   X_attribute14          => X_doc_attribute14,
	   X_attribute15          => X_doc_attribute15,
           X_create_doc           => l_create_doc,
	   X_url		  => X_url,
	   X_title		  => X_title,
           X_dm_node              => X_dm_node,
           X_dm_folder_path       => X_dm_folder_path,
           X_dm_type              => X_dm_type,
           X_dm_document_id       => X_dm_document_id,
           X_dm_version_number    => X_dm_version_number);

  END IF;    --  done creating document

  INSERT INTO fnd_attached_documents (
     attached_document_id,
     document_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     seq_num,
     entity_name,
     column1,
     pk1_value,
     pk2_value,
     pk3_value,
     pk4_value,
     pk5_value,
     automatically_added_flag,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     category_id) VALUES (
     X_attached_document_id,
     X_document_id,
     X_creation_date,
     X_created_by,
     X_last_update_date,
     X_last_updated_by,
     X_last_update_login,
     X_seq_num,
     X_entity_name,
     X_column1,
     X_pk1_value,
     X_pk2_value,
     X_pk3_value,
     X_pk4_value,
     X_pk5_value,
     X_automatically_added_flag,
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
     X_category_id);

  --  get rowid to pass back to form
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

END insert_row;




PROCEDURE Lock_Row(X_Rowid                        VARCHAR2,
                   X_attached_document_id         NUMBER,
                   X_document_id                  NUMBER,
                   X_seq_num                      NUMBER,
                   X_entity_name                  VARCHAR2,
                   X_column1                      VARCHAR2,
                   X_pk1_value                       VARCHAR2,
                   X_pk2_value                       VARCHAR2,
                   X_pk3_value                       VARCHAR2,
                   X_pk4_value                       VARCHAR2,
                   X_pk5_value                       VARCHAR2,
	           X_automatically_added_flag     VARCHAR2,
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
                  /*  columns necessary for creating a document on the fly */
                  X_datatype_id                  NUMBER,
                  X_category_id                  NUMBER,
                  X_security_type                NUMBER,
                  X_security_id                  NUMBER DEFAULT NULL,
                  X_publish_flag                 VARCHAR2,
                  X_image_type                   VARCHAR2 DEFAULT NULL,
                  X_storage_type                 NUMBER DEFAULT NULL,
                  X_usage_type                   VARCHAR2,
                  X_start_date_Active            DATE,
                  X_end_date_Active              DATE,
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
		  X_doc_attribute_category       VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute1               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute2               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute3               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute4               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute5               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute6               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute7               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute8               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute9               VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute10              VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute11              VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute12              VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute13              VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute14              VARCHAR2 DEFAULT NULL,
	 	  X_doc_attribute15              VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL) IS
  CURSOR C IS
      SELECT *
      FROM   fnd_attached_documents
      WHERE  rowid = X_Rowid
      FOR UPDATE of attached_document_id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
--    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  if (
          (   (Recinfo.attached_document_id = X_attached_document_id) )
      AND (   (Recinfo.document_id  = X_document_id) )
      AND (   (Recinfo.seq_num  = X_seq_num) )
      AND (   (Recinfo.entity_name  = X_entity_name) )
      AND (   (Recinfo.pk1_value = X_pk1_value)
           OR (    (Recinfo.pk1_value IS NULL)
               AND (X_pk1_value IS NULL)))
      AND (   (Recinfo.pk2_value = X_pk2_value)
           OR (    (Recinfo.pk2_value IS NULL)
               AND (X_pk2_value IS NULL)))
      AND (   (Recinfo.pk3_value = X_pk3_value)
           OR (    (Recinfo.pk3_value IS NULL)
               AND (X_pk3_value IS NULL)))
      AND (   (Recinfo.pk4_value = X_pk4_value)
           OR (    (Recinfo.pk4_value IS NULL)
               AND (X_pk4_value IS NULL)))
      AND (   (Recinfo.pk5_value = X_pk5_value)
           OR (    (Recinfo.pk5_value IS NULL)
               AND (X_pk5_value IS NULL)))
      AND (   (Recinfo.automatically_added_flag  =
                 X_automatically_added_flag) )
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
          ) then
    --  lock document as it's most likely what's changed!
    fnd_documents_pkg.lock_row(X_document_id       =>  X_document_id,
           X_datatype_id       =>  X_datatype_id,
           X_category_id       =>  X_category_id,
           X_security_type     =>  X_security_type,
           X_security_id       =>  X_security_id,
           X_publish_flag      =>  X_publish_flag,
           X_image_type        =>  X_image_type,
           X_storage_type      =>  X_storage_type,
           X_usage_type        =>  X_usage_type,
           X_start_date_active =>  X_start_date_Active,
           X_end_date_active   =>  X_end_date_Active,
           X_language          =>  X_language,
           X_description       =>  X_description,
           X_file_name         =>  X_file_name,
           X_media_id          =>  X_media_id,
           X_Attribute_Category => X_doc_attribute_category,
           X_Attribute1        => X_doc_attribute1,
           X_Attribute2        => X_doc_attribute2,
           X_Attribute3        => X_doc_attribute3,
           X_Attribute4        => X_doc_attribute4,
           X_Attribute5        => X_doc_attribute5,
           X_Attribute6        => X_doc_attribute6,
           X_Attribute7        => X_doc_attribute7,
           X_Attribute8        => X_doc_attribute8,
           X_Attribute9        => X_doc_attribute9,
           X_Attribute10       => X_doc_attribute10,
           X_Attribute11       => X_doc_attribute11,
           X_Attribute12       => X_doc_attribute12,
           X_Attribute13       => X_doc_attribute13,
           X_Attribute14       => X_doc_attribute14,
           X_Attribute15       => X_doc_attribute15,
	   X_url		  => X_url,
	   X_title		  => X_title);

      return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

END lock_Row;



PROCEDURE Update_Row(X_Rowid                        VARCHAR2,
                     X_attached_document_id         NUMBER,
                     X_document_id                  NUMBER,
                     X_last_update_date             DATE,
                     X_last_updated_by              NUMBER,
                     X_last_update_login            NUMBER DEFAULT NULL,
                     X_seq_num                      NUMBER,
                     X_entity_name                  VARCHAR2,
                     X_column1                      VARCHAR2,
                     X_pk1_value                    VARCHAR2,
                     X_pk2_value                    VARCHAR2,
                     X_pk3_value                    VARCHAR2,
                     X_pk4_value                    VARCHAR2,
                     X_pk5_value                    VARCHAR2,
	             X_automatically_added_flag     VARCHAR2,
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
                  /*  columns necessary for creating a document on the fly */
                  X_datatype_id                  NUMBER,
                  X_category_id                  NUMBER,
                  X_security_type                NUMBER,
                  X_security_id                  NUMBER DEFAULT NULL,
                  X_publish_flag                 VARCHAR2,
                  X_image_type                   VARCHAR2 DEFAULT NULL,
                  X_storage_type                 NUMBER DEFAULT NULL,
                  X_usage_type                VARCHAR2,
                  X_start_date_active            DATE,
                  X_end_date_active              DATE,
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
		  X_doc_attribute_category       VARCHAR2 DEFAULT NULL,
		  X_doc_attribute1               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute2               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute3               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute4               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute5               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute6               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute7               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute8               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute9               VARCHAR2 DEFAULT NULL,
		  X_doc_attribute10              VARCHAR2 DEFAULT NULL,
		  X_doc_attribute11              VARCHAR2 DEFAULT NULL,
		  X_doc_attribute12              VARCHAR2 DEFAULT NULL,
		  X_doc_attribute13              VARCHAR2 DEFAULT NULL,
		  X_doc_attribute14              VARCHAR2 DEFAULT NULL,
		  X_doc_attribute15              VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL
                  ) IS
BEGIN

  --  Update the attached_documents table
  UPDATE fnd_attached_documents
    SET  attached_document_id = X_attached_document_id,
         document_id          = X_document_id,
         last_update_date     = X_last_update_date,
         last_updated_by      = X_last_updated_by,
         last_update_login    = X_last_update_login,
         seq_num	      = X_seq_num,
         entity_name          = X_entity_name,
         column1	      = X_column1,
         pk1_value 	      = X_pk1_value,
         pk2_value 	      = X_pk2_value,
         pk3_value            = X_pk3_value,
         pk4_value            = X_pk4_value,
         pk5_value            = X_pk5_value,
         automatically_added_flag = X_automatically_added_flag,
         attribute_category   = X_attribute_category,
         attribute1	      = X_attribute1,
         attribute2	      = X_attribute2,
         attribute3           = X_attribute3,
         attribute4	      = X_attribute4,
         attribute5           = X_attribute5,
         attribute6           = X_attribute6,
         attribute7	      = X_attribute7,
         attribute8	      = X_attribute8,
         attribute9	      = X_attribute9,
         attribute10	      = X_attribute10,
         attribute11	      = X_attribute11,
         attribute12	      = X_attribute12,
         attribute13	      = X_attribute13,
         attribute14          = X_attribute14,
         attribute15	      = X_attribute15,
	 category_id          = X_category_id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  --  Call stored procedure to update document tables
  fnd_documents_pkg.Update_Row(X_document_id => X_document_id,
                     X_last_update_date      => X_last_update_date,
                     X_last_updated_by       => X_last_updated_by,
                     X_last_update_login     => X_last_update_login,
                     X_datatype_id           => X_datatype_id,
                     X_category_id           => X_category_id,
                     X_security_type         => X_security_type,
                     X_security_id           => X_security_id,
                     X_publish_flag          => X_publish_flag,
                     X_image_type            => X_image_type,
                     X_storage_type          => X_storage_type,
                     X_usage_type            => X_usage_type,
                     X_start_date_active     => X_start_date_active,
                     X_end_date_active       => X_end_date_active,
                     X_language              => X_language,
                     X_description           => X_description,
                     X_file_name             => X_file_name,
                     X_media_id              => X_media_id,
                  X_Attribute_Category => X_doc_attribute_category,
                  X_Attribute1         => X_doc_attribute1,
                  X_Attribute2         => X_doc_attribute2,
                  X_Attribute3         => X_doc_attribute3,
                  X_Attribute4         => X_doc_attribute4,
                  X_Attribute5         => X_doc_attribute5,
                  X_Attribute6         => X_doc_attribute6,
                  X_Attribute7         => X_doc_attribute7,
                  X_Attribute8         => X_doc_attribute8,
                  X_Attribute9         => X_doc_attribute9,
                  X_Attribute10        => X_doc_attribute10,
                  X_Attribute11        => X_doc_attribute11,
                  X_Attribute12        => X_doc_attribute12,
                  X_Attribute13        => X_doc_attribute13,
                  X_Attribute14        => X_doc_attribute14,
                  X_Attribute15        => X_doc_attribute15,
		  X_url		       => X_url,
                  X_title	       => X_title,
                  X_dm_node              => X_dm_node,
                  X_dm_folder_path       => X_dm_folder_path,
                  X_dm_type              => X_dm_type,
                  X_dm_document_id       => X_dm_document_id,
                  X_dm_version_number    => X_dm_version_number);

END update_row;

END fnd_attached_documents_pkg;

/
