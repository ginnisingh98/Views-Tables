--------------------------------------------------------
--  DDL for Package DOM_ATTACHMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_ATTACHMENT_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: DOMAUTLS.pls 120.5 2006/09/20 19:03:05 sabatra noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public APIs for  Attachments functionality          |
 +---------------------------------------------------------------------------*/


Procedure Attach (
   p_Document_id               IN Number
  , p_Entity_name              IN Varchar2
  , p_Pk1_value                IN Varchar2
  , p_Pk2_value                IN Varchar2 DEFAULT NULL
  , p_Pk3_value                IN Varchar2 DEFAULT NULL
  , p_Pk4_value                IN Varchar2 DEFAULT NULL
  , p_Pk5_value                IN Varchar2 DEFAULT NULL
  , p_category_id              IN Number
  , p_created_by               IN Number
  , p_last_update_login        IN Number DEFAULT NULL
  , x_Attached_document_id     OUT NOCOPY Number
);

Procedure Create_Attachment (
    p_Document_id               IN Number
  , p_Entity_name              IN Varchar2
  , p_Pk1_value                IN Varchar2
  , p_Pk2_value                IN Varchar2 DEFAULT NULL
  , p_Pk3_value                IN Varchar2 DEFAULT NULL
  , p_Pk4_value                IN Varchar2 DEFAULT NULL
  , p_Pk5_value                IN Varchar2 DEFAULT NULL
  , p_category_id              IN Number
  , p_repository_id	       IN NUMBER
  , p_version_id	       IN NUMBER
  , p_family_id		       IN NUMBER
  , p_file_name		       IN VARCHAR2
  , p_created_by               IN NUMBER
  , p_last_update_login        IN NUMBER DEFAULT NULL
  , x_Attached_document_id     OUT NOCOPY NUMBER
);

Procedure Detach(
    p_Attached_document_id      IN Number
);

/* This will be called after the MODIFY action */
Procedure Update_Document(
     p_Attached_document_id     IN Number
    , p_FileName                IN Varchar2
    , p_Description             IN Varchar2 DEFAULT NULL
    , p_Category                IN Number
    , p_last_updated_by         IN Number
    , p_last_update_login       IN Number DEFAULT NULL
);

/* To be called for change attach version */
Procedure Change_Version(
     p_Attached_document_id      IN Number
   , p_Document_id               IN Number
   , p_last_updated_by           IN Number
   , p_last_update_login         IN Number DEFAULT NULL
);

/* This procedure is after approval / review to change fnd document
status */
Procedure Change_Status(
     p_Attached_document_id      IN Number
   , p_Document_id               IN Number
   , p_Repository_id             IN Number
   , p_Status                    IN Varchar2
   , p_submitted_by              IN Number
   , p_last_updated_by           IN Number
   , p_last_update_login         IN Number DEFAULT NULL
);

/* This function returns document rendering url */
FUNCTION get_repos_doc_view_url
  (
    p_document_id      IN  NUMBER
  )RETURN VARCHAR2;

--  API to delete attachments for a given entity
PROCEDURE delete_attachments(X_entity_name IN VARCHAR2,
		X_pk1_value IN VARCHAR2,
		X_pk2_value IN VARCHAR2 DEFAULT NULL,
		X_pk3_value IN VARCHAR2 DEFAULT NULL,
		X_pk4_value IN VARCHAR2 DEFAULT NULL,
		X_pk5_value IN VARCHAR2 DEFAULT NULL,
		X_delete_document_flag IN VARCHAR2 DEFAULT 'N',
		X_automatically_added_flag IN VARCHAR2 DEFAULT NULL);

PROCEDURE copy_documents(X_from_document_id IN OUT NOCOPY NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) ;

--  API to copy attachments from one record to another
PROCEDURE copy_attachments(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_from_attachment_id IN NUMBER DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_to_attachment_id IN OUT NOCOPY NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
		  X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL );

END DOM_ATTACHMENT_UTIL_PKG;

 

/
