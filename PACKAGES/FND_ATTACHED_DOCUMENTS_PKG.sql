--------------------------------------------------------
--  DDL for Package FND_ATTACHED_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ATTACHED_DOCUMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFAKAADS.pls 120.2.12010000.2 2010/08/31 16:04:37 ctilley ship $ */



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
                  X_usage_type                   VARCHAR2 DEFAULT 'O',
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
                  X_doc_Attribute_Category       VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute1               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute2               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute3               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute4               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute5               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute6               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute7               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute8               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute9               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute10              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute11              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute12              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute13              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute14              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute15              VARCHAR2 DEFAULT NULL,
		  X_create_doc                   VARCHAR2 DEFAULT 'N',
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL
 );


PROCEDURE Lock_Row(X_Rowid                        VARCHAR2,
                   X_attached_document_id         NUMBER,
                   X_document_id                  NUMBER,
                   X_seq_num                      NUMBER,
                   X_entity_name                  VARCHAR2,
                   X_column1                      VARCHAR2,
                   X_pk1_value                    VARCHAR2,
                   X_pk2_value                    VARCHAR2,
                   X_pk3_value                    VARCHAR2,
                   X_pk4_value                    VARCHAR2,
                   X_pk5_value                    VARCHAR2,
	           X_automatically_added_flag     VARCHAR2,
                   X_Attribute_Category                 VARCHAR2 DEFAULT NULL,
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
                  X_start_date_active            DATE,
                  X_end_date_active              DATE,
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
                  X_doc_Attribute_Category       VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute1               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute2               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute3               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute4               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute5               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute6               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute7               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute8               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute9               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute10              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute11              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute12              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute13              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute14              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute15              VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL);


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
                  X_usage_type                   VARCHAR2,
                  X_start_date_active            DATE,
                  X_end_date_active              DATE,
                  X_language                     VARCHAR2,
                  X_description                  VARCHAR2 DEFAULT NULL,
                  X_file_name                    VARCHAR2 DEFAULT NULL,
                  X_media_id                     IN OUT NOCOPY NUMBER,
                  X_doc_Attribute_Category       VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute1               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute2               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute3               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute4               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute5               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute6               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute7               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute8               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute9               VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute10              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute11              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute12              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute13              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute14              VARCHAR2 DEFAULT NULL,
                  X_doc_Attribute15              VARCHAR2 DEFAULT NULL,
                  X_url                          VARCHAR2 DEFAULT NULL,
                  X_title			 VARCHAR2 DEFAULT NULL,
                  X_dm_node                      NUMBER DEFAULT NULL,
                  X_dm_folder_path               VARCHAR2 DEFAULT NULL,
                  X_dm_type                      VARCHAR2 DEFAULT NULL,
                  X_dm_document_id               NUMBER DEFAULT NULL,
                  X_dm_version_number            VARCHAR2 DEFAULT NULL
);



END fnd_attached_documents_pkg;

/