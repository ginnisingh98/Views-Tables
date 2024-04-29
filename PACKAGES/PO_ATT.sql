--------------------------------------------------------
--  DDL for Package PO_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ATT" AUTHID CURRENT_USER AS
/* $Header: poatt04s.pls 120.0.12010000.1 2008/09/18 12:20:36 appldev noship $ */
  update_doc_flag VARCHAR2 (20) := 'UPDATE';
  update_ref_flag VARCHAR2 (20) := 'UPDATE';

PROCEDURE mark_record (
  p_src_id      NUMBER,      -- media_id | document_id
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'PO_10SC' | 'PO_R10'
);

PROCEDURE clear_mark (
  p_short_long  VARCHAR2, -- 'S' | 'L'
  p_source      VARCHAR2,-- 'DOCUMENT' | 'NOTE'
  p_operation   VARCHAR2,-- 'INSERT' | 'UPDATE'
  p_version     VARCHAR2 -- 'PO_10SC' | 'PO_R10'
);

FUNCTION get_table_name (
  p_entity_name VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_table_name (
  p_document_id NUMBER
) RETURN VARCHAR2;

FUNCTION get_column_name (
  p_entity_name VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_column_name (
  p_document_id NUMBER
) RETURN VARCHAR2;

FUNCTION get_entity_name (
  p_table_name  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE get_category_id (
  p_usage_id    NUMBER,
  p_category_id OUT NOCOPY NUMBER
);

PROCEDURE get_usage_id (
  p_category_id NUMBER,
  p_usage_id    OUT NOCOPY NUMBER
);

PROCEDURE get_media_id (
  p_document_id   NUMBER,
  p_media_id      OUT NOCOPY NUMBER,
  p_datatype_id   OUT NOCOPY NUMBER
);

PROCEDURE get_document_id (
  p_media_id      NUMBER,
  p_datatype_id   VARCHAR2,
  p_document_id   OUT NOCOPY NUMBER
);

PROCEDURE get_note_info (
  p_media_id      NUMBER,
  p_short_long    VARCHAR2,
  p_document_id   OUT NOCOPY NUMBER,
  p_category_id   OUT NOCOPY NUMBER,
  p_usage_id      OUT NOCOPY NUMBER,
  p_note_type     OUT NOCOPY VARCHAR2 -- 'O' | 'S'
);

PROCEDURE insert_document (
    p_note_id            NUMBER,
    p_app_source_version VARCHAR2
);

PROCEDURE update_document (
  p_note_id            NUMBER,
  p_app_source_version VARCHAR2
);

PROCEDURE delete_document (
  p_document_id  NUMBER
);

PROCEDURE insert_attached_document (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  p_attached_doc_id     OUT NOCOPY NUMBER
);
PROCEDURE insert_attached_document_item (
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  p_attached_doc_id     OUT NOCOPY NUMBER
);

PROCEDURE update_attached_document (
  p_attached_doc_id         NUMBER,
  p_creation_date           DATE,
  p_created_by              NUMBER,
  p_po_note_id              NUMBER,
  p_table_name              VARCHAR2,
  p_column_name             VARCHAR2,
  p_foreign_id              NUMBER,
  p_sequence_num            NUMBER,
  p_attribute_category      VARCHAR2,
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
  p_attached_doc_id         NUMBER
);

END;

/
