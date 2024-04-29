--------------------------------------------------------
--  DDL for Package WSH_DOC_SEQ_CTG_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DOC_SEQ_CTG_S" AUTHID CURRENT_USER AS
-- $Header: WSHVDOCS.pls 115.4 2002/11/12 02:05:02 nparikh ship $

--------------------
-- TYPE DECLARATIONS
--------------------

-- currently not used. planned to be used as the parameter for a cover routine
-- that accepts a record type and in turn calls the table handler procedures

TYPE category_rectype  IS RECORD
  ( row_id                  varchar2(200) -- to confirm this length
  , doc_sequence_category_id
    wsh_doc_sequence_categories.doc_sequence_category_id%type
  , location_id             wsh_doc_sequence_categories.location_id%type
  , document_type           wsh_doc_sequence_categories.document_type%type
  , document_code           wsh_doc_sequence_categories.document_code%type
  , application_id          wsh_doc_sequence_categories.application_id%type
  , category_code           wsh_doc_sequence_categories.category_code%type
  , prefix                  wsh_doc_sequence_categories.prefix%type
  , suffix                  wsh_doc_sequence_categories.suffix%type
  , delimiter               wsh_doc_sequence_categories.delimiter%type
  , enabled_flag            wsh_doc_sequence_categories.enabled_flag%type
  , created_by              wsh_doc_sequence_categories.created_by%type
  , creation_date           wsh_doc_sequence_categories.creation_date%type
  , last_updated_by         wsh_doc_sequence_categories.last_updated_by%type
  , last_update_date        wsh_doc_sequence_categories.last_update_date%type
  , last_update_login       wsh_doc_sequence_categories.last_update_login%type
  , program_application_id
    wsh_doc_sequence_categories.program_application_id%type
  , program_id              wsh_doc_sequence_categories.program_id%type
  , program_update_date     wsh_doc_sequence_categories.program_update_date%type
  , request_id              wsh_doc_sequence_categories.request_id%type
  , attribute_category      wsh_doc_sequence_categories.attribute_category%type
  , attribute1              wsh_doc_sequence_categories.attribute1%type
  , attribute2              wsh_doc_sequence_categories.attribute2%type
  , attribute3              wsh_doc_sequence_categories.attribute3%type
  , attribute4              wsh_doc_sequence_categories.attribute4%type
  , attribute5              wsh_doc_sequence_categories.attribute5%type
  , attribute6              wsh_doc_sequence_categories.attribute6%type
  , attribute7              wsh_doc_sequence_categories.attribute7%type
  , attribute8              wsh_doc_sequence_categories.attribute8%type
  , attribute9              wsh_doc_sequence_categories.attribute9%type
  , attribute10             wsh_doc_sequence_categories.attribute10%type
  , attribute11             wsh_doc_sequence_categories.attribute11%type
  , attribute12             wsh_doc_sequence_categories.attribute12%type
  , attribute13             wsh_doc_sequence_categories.attribute13%type
  , attribute14             wsh_doc_sequence_categories.attribute14%type
  , attribute15             wsh_doc_sequence_categories.attribute15%type
);


------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------


PROCEDURE insert_row
  ( x_rowid                       IN OUT NOCOPY  VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_name                        VARCHAR2
  , x_description                 VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
);


PROCEDURE update_row
  ( x_rowid                       VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_name                        VARCHAR2
  , x_description                 VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
);

PROCEDURE lock_row
  ( x_rowid                       VARCHAR2
  , x_doc_sequence_category_id    NUMBER
  , x_location_id                 NUMBER
  , x_document_type               VARCHAR2
  , x_document_code               VARCHAR2
  , x_application_id              VARCHAR2
  , x_category_code               VARCHAR2
  , x_prefix                      VARCHAR2
  , x_suffix                      VARCHAR2
  , x_delimiter                   VARCHAR2
  , x_enabled_flag                VARCHAR2
  , x_created_by                  NUMBER
  , x_creation_date               DATE
  , x_last_updated_by             NUMBER
  , x_last_update_date            DATE
  , x_last_update_login           NUMBER
  , x_program_application_id      NUMBER
  , x_program_id                  NUMBER
  , x_program_update_date         DATE
  , x_request_id                  NUMBER
  , x_attribute_category          VARCHAR2
  , x_attribute1                  VARCHAR2
  , x_attribute2                  VARCHAR2
  , x_attribute3                  VARCHAR2
  , x_attribute4                  VARCHAR2
  , x_attribute5                  VARCHAR2
  , x_attribute6                  VARCHAR2
  , x_attribute7                  VARCHAR2
  , x_attribute8                  VARCHAR2
  , x_attribute9                  VARCHAR2
  , x_attribute10                 VARCHAR2
  , x_attribute11                 VARCHAR2
  , x_attribute12                 VARCHAR2
  , x_attribute13                 VARCHAR2
  , x_attribute14                 VARCHAR2
  , x_attribute15                 VARCHAR2
);

PROCEDURE delete_row ( x_rowid VARCHAR2 );

END wsh_doc_seq_ctg_s;

 

/
