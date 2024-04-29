--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtatvs.pls 115.1 2002/12/10 19:39:54 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALIDATION_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
			px_enty_attr_validation_id		IN OUT NOCOPY NUMBER,
			p_last_update_date				DATE,
			p_last_updated_by				NUMBER,
			p_creation_date					DATE,
			p_created_by					NUMBER,
			p_last_update_login				NUMBER,
			px_object_version_number		IN OUT NOCOPY NUMBER,
			p_validation_date				DATE,
			p_validated_by_resource_id      NUMBER,
			p_validation_document_id	    NUMBER,
			p_validation_note				VARCHAR2
			);

PROCEDURE Update_Row(
			p_enty_attr_validation_id		NUMBER,
			p_last_update_date				DATE,
			p_last_updated_by				NUMBER,
			p_last_update_login				NUMBER,
			p_object_version_number			NUMBER,
			p_validation_date				DATE,
			p_validated_by_resource_id		NUMBER,
			p_validation_document_id		NUMBER,
			p_validation_note				VARCHAR2
			);

PROCEDURE Delete_Row(
			p_enty_attr_validation_id			NUMBER
           );



PROCEDURE Lock_Row(
			p_enty_attr_validation_id			NUMBER,
			p_last_update_date				DATE,
			p_last_updated_by				NUMBER,
			p_creation_date					DATE,
			p_created_by					NUMBER,
			p_last_update_login				NUMBER,
			p_object_version_number			NUMBER,
			p_validation_date				DATE,
			p_validated_by_resource_id		NUMBER,
			p_validation_document_id		NUMBER,
			p_validation_note				VARCHAR2
			);




END PV_ENTY_ATTR_VALIDATIONS_PKG;

 

/
