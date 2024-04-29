--------------------------------------------------------
--  DDL for Package JTF_IH_WRAP_UPS_SEED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_WRAP_UPS_SEED_PUB" AUTHID CURRENT_USER AS
 /* $Header: JTFIHWPS.pls 120.2 2005/07/08 08:35:35 nchouras ship $ */

     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_wrap_id                          NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_outcome_required                 VARCHAR2
        , x_result_required                  VARCHAR2
        , x_reason_required                  VARCHAR2
        , x_result_id                        NUMBER
        , x_reason_id                        NUMBER
        , x_outcome_id                       NUMBER
        , x_action_activity_id               NUMBER
        , x_object_id                        NUMBER
        , x_object_type                      VARCHAR2
        , x_source_code_id                   NUMBER
        , x_source_code                      VARCHAR2
        , x_start_date                       DATE DEFAULT NULL
        , x_end_date                         DATE DEFAULT NULL
        , x_wrap_up_level                    VARCHAR2
     );

     PROCEDURE delete_row(
        x_wrap_id                          NUMBER
     );

     PROCEDURE update_row(
          x_wrap_id                        NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_outcome_required               VARCHAR2
        , x_result_required                VARCHAR2
        , x_reason_required                VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_action_activity_id             NUMBER
        , x_object_id                      NUMBER
        , x_object_type                    VARCHAR2
        , x_source_code_id                 NUMBER
        , x_source_code                    VARCHAR2
        , x_start_date                       DATE DEFAULT NULL
        , x_end_date                         DATE DEFAULT NULL
        , x_wrap_up_level                    VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_wrap_id                        NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_outcome_required               VARCHAR2
        , x_result_required                VARCHAR2
        , x_reason_required                VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_action_activity_id             NUMBER
        , x_object_id                      NUMBER
        , x_object_type                    VARCHAR2
        , x_source_code_id                 NUMBER
        , x_source_code                    VARCHAR2
     );

    PROCEDURE load_row(
          x_wrap_id                           NUMBER
        , x_object_version_number             NUMBER
        , x_outcome_required                  VARCHAR2
        , x_result_required                   VARCHAR2
        , x_reason_required                   VARCHAR2
        , x_result_id                         NUMBER
        , x_reason_id                         NUMBER
        , x_outcome_id                        NUMBER
        , x_action_activity_id                NUMBER
        , x_object_id                         NUMBER
        , x_object_type                       VARCHAR2
        , x_source_code_id                    NUMBER
        , x_source_code                       VARCHAR2
        , x_start_date                        DATE DEFAULT NULL
        , x_end_date                          DATE DEFAULT NULL
        , x_owner                             VARCHAR2
        , x_wrap_up_level                    VARCHAR2
    );

    PROCEDURE load_seed_row(
          x_wrap_id                           NUMBER
        , x_object_version_number             NUMBER
        , x_outcome_required                  VARCHAR2
        , x_result_required                   VARCHAR2
        , x_reason_required                   VARCHAR2
        , x_result_id                         NUMBER
        , x_reason_id                         NUMBER
        , x_outcome_id                        NUMBER
        , x_action_activity_id                NUMBER
        , x_object_id                         NUMBER
        , x_object_type                       VARCHAR2
        , x_source_code_id                    NUMBER
        , x_source_code                       VARCHAR2
        , x_start_date                        DATE DEFAULT NULL
        , x_end_date                          DATE DEFAULT NULL
        , x_owner                             VARCHAR2
        , x_wrap_up_level                     VARCHAR2
	, x_upload_mode			      VARCHAR2
    );

END JTF_IH_WRAP_UPS_SEED_PUB;

 

/
