--------------------------------------------------------
--  DDL for Package FND_ATTACHED_DOCUMENTS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ATTACHED_DOCUMENTS2_PKG" AUTHID CURRENT_USER as
/* $Header: AFAKATDS.pls 120.1.12010000.1 2008/07/25 14:09:29 appldev ship $ */


--  API to delete attachments for a given entity
PROCEDURE delete_attachments(X_entity_name IN VARCHAR2,
		X_pk1_value IN VARCHAR2,
		X_pk2_value IN VARCHAR2 DEFAULT NULL,
		X_pk3_value IN VARCHAR2 DEFAULT NULL,
		X_pk4_value IN VARCHAR2 DEFAULT NULL,
		X_pk5_value IN VARCHAR2 DEFAULT NULL,
		X_delete_document_flag IN VARCHAR2 DEFAULT 'N',
		X_automatically_added_flag IN VARCHAR2 DEFAULT NULL);



--  API to copy attachments from one record to another
--  BUG#2790775
--  Added the default parameters X_from_category_id and X_to_category_id
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
			X_to_category_id IN NUMBER DEFAULT NULL);


END fnd_attached_documents2_pkg;

/
