--------------------------------------------------------
--  DDL for Package SO_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SO_ATT" AUTHID CURRENT_USER AS
/* $Header: oeatt04s.pls 115.1 99/07/16 08:25:23 porting shi $ */
  update_doc_flag VARCHAR2 (20) := 'UPDATE';
  update_ref_flag VARCHAR2 (20) := 'UPDATE';

PROCEDURE mark_record (
  p_src_id      NUMBER,      -- media_id | document_id
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- '10SC' | 'R10'
);

PROCEDURE clear_mark (
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- '10SC' | 'R10'
);

FUNCTION get_note_name  (
  p_document_id NUMBER
) RETURN VARCHAR2;

FUNCTION get_note_error (
 p_msg_name VARCHAR2,
 p_document_id NUMBER DEFAULT NULL
) RETURN VARCHAR2;


FUNCTION get_document_usage_type  (
  p_note_id NUMBER
) RETURN VARCHAR2;

FUNCTION get_entity_name (p_header_id IN NUMBER, p_line_id IN NUMBER)
 RETURN VARCHAR2;

PROCEDURE get_category_id (
  p_usage_id    NUMBER,
  p_category_id OUT NUMBER
);

PROCEDURE get_usage_id (
  p_category_id NUMBER,
  p_usage_id    OUT NUMBER
);

PROCEDURE get_media_id (
  p_document_id   NUMBER,
  p_media_id      OUT NUMBER,
  p_datatype_id   OUT NUMBER
);

FUNCTION get_doc_cat_application(p_document_id IN NUMBER) RETURN NUMBER;
FUNCTION get_cat_application(p_category_id IN NUMBER) RETURN NUMBER;

PROCEDURE get_note_info (
  p_media_id      NUMBER,
  p_short_long    VARCHAR2,
  p_document_id   OUT NUMBER,
  p_category_id   OUT NUMBER,
  p_usage_id      OUT NUMBER,
  p_usage_type    OUT VARCHAR2, -- 'O' | 'S'
  p_application_id OUT NUMBER
);

PROCEDURE get_note_type_code (
 p_usage_type    VARCHAR2,
 p_note_type_code  OUT VARCHAR2, -- 'SN' | 'OT'
 p_override_flag   OUT VARCHAR2  -- 'Y'  | 'N'
);

PROCEDURE insert_document (
    p_document_id        NUMBER,
    p_app_source_version VARCHAR2
);

PROCEDURE update_document (
  p_document_id        NUMBER,
  p_app_source_version VARCHAR2
);

PROCEDURE delete_document (
  p_document_id  NUMBER
);


PROCEDURE insert_attached_document (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_note_id                 NUMBER,
  p_usage_id                NUMBER,
  p_automatically_added_flag VARCHAR2,
  p_header_id               NUMBER,
  p_line_id                 NUMBER,
  p_program_application_id  NUMBER,
  p_program_id              NUMBER,
  p_program_update_date     DATE,
  p_request_id              NUMBER,
  p_sequence_number         NUMBER,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2,
  p_attached_document_id    IN OUT NUMBER
);

PROCEDURE update_attached_document (
  p_attached_document_id    NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_note_id                 NUMBER,
  p_usage_id                NUMBER,
  p_automatically_added_flag VARCHAR2,
  p_header_id               NUMBER,
  p_line_id                 NUMBER,
  p_program_application_id  NUMBER,
  p_program_id              NUMBER,
  p_program_update_date     DATE,
  p_request_id              NUMBER,
  p_sequence_number         NUMBER,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2
);

PROCEDURE delete_attached_document (
  p_attached_document_id         NUMBER
);

PROCEDURE insert_category (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_description             VARCHAR2,
  p_start_date_active       DATE,
  p_end_date_active         DATE,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2,
  p_category_id             IN OUT NUMBER
);

PROCEDURE update_category (
  p_category_id             NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_description             VARCHAR2,
  p_start_date_active       DATE,
  p_end_date_active         DATE,
  p_context                 VARCHAR2,
  p_attribute1              VARCHAR2,
  p_attribute2              VARCHAR2,
  p_attribute3              VARCHAR2,
  p_attribute4              VARCHAR2,
  p_attribute5              VARCHAR2,
  p_attribute6              VARCHAR2,
  p_attribute7              VARCHAR2,
  p_attribute8              VARCHAR2,
  p_attribute9              VARCHAR2,
  p_attribute10             VARCHAR2,
  p_attribute11             VARCHAR2,
  p_attribute12             VARCHAR2,
  p_attribute13             VARCHAR2,
  p_attribute14             VARCHAR2,
  p_attribute15             VARCHAR2,
  p_app_source_version      VARCHAR2
);

PROCEDURE insert_usage (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_user_name               VARCHAR2,
  p_category_id             NUMBER,
  p_app_source_version      VARCHAR2,
  p_usage_id                IN OUT NUMBER
);

PROCEDURE update_usage (
  p_category_id             NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_last_update_date        DATE,
  p_last_updated_by         NUMBER,
  p_last_update_login       NUMBER,
  p_name                    VARCHAR2,
  p_user_name               VARCHAR2,
  p_app_source_version      VARCHAR2
);

END;

 

/
