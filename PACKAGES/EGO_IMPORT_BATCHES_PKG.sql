--------------------------------------------------------
--  DDL for Package EGO_IMPORT_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOVBATS.pls 120.0.12010000.2 2009/04/02 01:57:13 geguo ship $ */

  PROCEDURE INSERT_ROW (
    X_ROWID                  IN OUT NOCOPY VARCHAR2,
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_CREATION_DATE          IN DATE,
    X_CREATED_BY             IN NUMBER,
    X_LAST_UPDATE_DATE       IN DATE,
    X_LAST_UPDATED_BY        IN NUMBER,
    X_LAST_UPDATE_LOGIN      IN NUMBER);

  PROCEDURE LOCK_ROW (
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2
  );

  PROCEDURE UPDATE_ROW (
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_LAST_UPDATE_DATE       IN DATE,
    X_LAST_UPDATED_BY        IN NUMBER,
    X_LAST_UPDATE_LOGIN      IN NUMBER
  );

  PROCEDURE DELETE_ROW (
    X_BATCH_ID               IN NUMBER
  );

  PROCEDURE ADD_LANGUAGE;

    Procedure CREATE_IMPORT_BATCH(p_source_system_code      IN VARCHAR2 DEFAULT 'PIMDH',
                                p_organization_id         IN NUMBER,
                                p_batch_type_display_name IN VARCHAR2 DEFAULT NULL,
                                p_assignee_name           IN VARCHAR2 DEFAULT NULL,
                                p_batch_name              IN VARCHAR2,
                                p_match_on_data_load       IN VARCHAR2 DEFAULT NULL,
                                p_apply_def_match_rule_all IN VARCHAR2 DEFAULT NULL,
                                p_confirm_single_match     IN VARCHAR2 DEFAULT NULL,
                                p_import_on_data_load      IN VARCHAR2 DEFAULT NULL,
                                p_import_xref_only         IN VARCHAR2 DEFAULT NULL,
                                p_revision_import_policy   IN VARCHAR2 DEFAULT NULL,
                                p_structure_name             IN VARCHAR2 DEFAULT NULL,
                                p_structure_effectivity_type IN NUMBER DEFAULT NULL,
                                p_effectivity_date           IN DATE DEFAULT SYSDATE,
                                p_from_end_item_unit_number  IN VARCHAR2 DEFAULT NULL,
                                p_structure_content          IN VARCHAR2 DEFAULT NULL,
                                p_change_order_creation  IN VARCHAR2 DEFAULT NULL,
                                p_add_all_to_change_flag IN VARCHAR2 DEFAULT NULL,
                                p_change_mgmt_type_code  IN VARCHAR2 DEFAULT NULL,
                                p_change_type_id         IN NUMBER DEFAULT NULL,
                                p_change_notice          IN VARCHAR2 DEFAULT NULL,
                                p_change_name            IN VARCHAR2 DEFAULT NULL,
                                p_change_description     IN VARCHAR2 DEFAULT NULL,
                                p_def_match_rule_cust_app_id IN NUMBER DEFAULT 431,
                                p_def_match_rule_cust_code   IN VARCHAR2 DEFAULT NULL,
                                p_nir_option            IN VARCHAR2 DEFAULT NULL,
                                p_enabled_for_data_pool IN VARCHAR2 DEFAULT NULL,
                                x_batch_id              OUT NOCOPY NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_error_msg             OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_BATCH_STATUS(p_batch_id      NUMBER,
                                p_batch_name    VARCHAR2,
                                p_batch_status  VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg     OUT NOCOPY VARCHAR2);

END EGO_IMPORT_BATCHES_PKG;

/
