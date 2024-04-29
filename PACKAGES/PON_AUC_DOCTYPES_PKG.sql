--------------------------------------------------------
--  DDL for Package PON_AUC_DOCTYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUC_DOCTYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: PONDOCTS.pls 120.3 2006/05/24 17:22:37 mxfang noship $ */



PROCEDURE insert_row (
     p_doctype_id                    IN  pon_auc_doctypes.doctype_id%TYPE
    ,p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE
    ,p_scope                         IN  pon_auc_doctypes.scope%TYPE
    ,p_status                        IN  pon_auc_doctypes.status%TYPE
    ,p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE
    ,p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE
    ,p_created_by                    IN  pon_auc_doctypes.created_by%TYPE
    ,p_creation_date                 IN  pon_auc_doctypes.creation_date%TYPE
    ,p_last_updated_by               IN  pon_auc_doctypes.last_updated_by%TYPE
    ,p_last_update_date              IN  pon_auc_doctypes.last_update_date%TYPE
    ,p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE
    ,p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE
    ,p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE
    ,p_name                          IN  pon_auc_doctypes_tl.name%TYPE);

PROCEDURE update_row (
    p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE,
    p_scope                         IN  pon_auc_doctypes.scope%TYPE,
    p_status                        IN  pon_auc_doctypes.status%TYPE,
    p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE,
    p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE,
    p_last_updated_by               IN  pon_auc_doctypes.last_updated_by%TYPE,
    p_last_update_date              IN  pon_auc_doctypes.last_update_date%TYPE,
    p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE,
    p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE,
    p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE,
    p_name                          IN  pon_auc_doctypes_tl.name%TYPE);

PROCEDURE translate_row (
     p_internal_name                IN  pon_auc_doctypes.internal_name%TYPE,
     p_name                         IN  pon_auc_doctypes_tl.name%TYPE,
     p_owner                        IN  VARCHAR2,
     p_custom_mode                  IN  VARCHAR2,
     p_last_update_date             IN  VARCHAR2);

PROCEDURE load_row (
    p_internal_name                 IN  pon_auc_doctypes.internal_name%TYPE,
    p_owner                         IN  VARCHAR2,
    p_last_update_date              IN  VARCHAR2,
    p_custom_mode                   IN  VARCHAR2, -- Custom mode can be FORCE
                                                  -- to force data to be uploaded
						  -- irrespective of current status
    p_scope                         IN  pon_auc_doctypes.scope%TYPE,
    p_status                        IN  pon_auc_doctypes.status%TYPE,
    p_transaction_type              IN  pon_auc_doctypes.transaction_type%TYPE,
    p_message_suffix                IN  pon_auc_doctypes.message_suffix%TYPE,
    p_doctype_group_name            IN  pon_auc_doctypes.doctype_group_name%TYPE,
    p_document_type_code            IN  pon_auc_doctypes.document_type_code%TYPE,
    p_document_subtype              IN  pon_auc_doctypes.document_subtype%TYPE,
    p_name                          IN  pon_auc_doctypes_tl.name%TYPE);


PROCEDURE delete_row (
            p_internal_name   pon_auc_doctypes.internal_name%TYPE
	        );

PROCEDURE add_language;

END pon_auc_doctypes_pkg;

 

/
