--------------------------------------------------------
--  DDL for Package CZ_MODEL_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MODEL_MIGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: czmdlmgs.pls 120.4 2006/01/30 07:27:40 srangar ship $ */

TYPE t_varchar40_array_tbl_type IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
TYPE t_num_array_tbl_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TARGET_SERVER_PUBLISH_ALLOW     CONSTANT VARCHAR2(1)  := '0';
TARGET_SERVER_PUBLISH_NOTALLOW  CONSTANT VARCHAR2(1)  := '1';
MODEL_PUBLICATION_OBSELETE      CONSTANT VARCHAR2(3)  := 'OBS';

MIGRATE_MODEL                   CONSTANT VARCHAR2(20) := 'MIGRATEMODEL';
MODE_MIGRATION                  CONSTANT VARCHAR2(1)  := 'M';
MODE_PUBLICATION                CONSTANT VARCHAR2(1)  := 'P';
MODE_COPY                       CONSTANT VARCHAR2(1)  := 'T';

PUB_SOURCE_FLAG                 CONSTANT VARCHAR2(1)  := 'S';
PUB_TARGET_FLAG                 CONSTANT VARCHAR2(1)  := 'T';
MIG_SOURCE_FLAG                 CONSTANT VARCHAR2(1)  := 'M';
MIG_TARGET_FLAG                 CONSTANT VARCHAR2(1)  := 'R';

CHANGE_FLAG_UNCHANGED           CONSTANT VARCHAR2(1)  := 'N';
---------------------------------------------------------------------------------------
/*
 * Public API for Model Migration.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 * @param p_userid     Standard parameters required for locking. Represent calling user.
 * @param p_respid     Standard parameters required for locking. Represent calling responsibility.
 * @param p_applid     Standard parameters required for locking. Represent calling application.
 * @param p_run_id     Number identifying the session. If left NULL, the API will generate the number and
 *                     return it in x_run_id.
 * @param x_run_id     Output parameter containing internally generated session identifier if p_run_id
 *                     was NULL, otherwise equal to p_run_id.
 */

PROCEDURE migrate_models(p_request_id  IN  NUMBER,
                         p_user_id     IN  NUMBER,
                         p_resp_id     IN  NUMBER,
                         p_appl_id     IN  NUMBER,
                         p_run_id      IN  NUMBER,
                         x_run_id      OUT NOCOPY NUMBER,
                         x_status      OUT NOCOPY VARCHAR2
                        );
---------------------------------------------------------------------------------------
/*
 * Migrate Models concurrent procedure.
 * @param errbuf       Standard Oracle Concurrent Program output parameters.
 * @param retcode      Standard Oracle Concurrent Program output parameters.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 */

PROCEDURE migrate_models_cp(errbuf       OUT NOCOPY VARCHAR2,
                            retcode      OUT NOCOPY NUMBER,
                            p_request_id IN  NUMBER
                           );
---------------------------------------------------------------------------------------
/*
 * Procedure for persistent id(s) allocation in migrated models.
 * @param p_model_id       devl_project_id of the model.
 * @param x_new_record_id  Candidate for the new id.
 */

PROCEDURE allocate_persistent_id(p_model_id      IN NUMBER,
                                 x_new_record_id IN OUT NOCOPY NUMBER
                                );
---------------------------------------------------------------------------------------
/*
 * Concurrent procedure for Configuration Upgrade by Item.
 * @param errbuf              Standard Oracle Concurrent Program output parameters.
 * @param retcode             Standard Oracle Concurrent Program output parameters.
 * @param p_organization_id   Used to search configurations by organization ID, required.
 * @param p_top_inv_item_from Used to search configurations by top item, required.
 * @param p_top_inv_item_to   Used to search configurations by top item, optional
 * @param p_application_id    Used to refine search for equivalent published models
 *                            to use as baselines for upgrade, optional.
 * @param p_config_begin_date Optional, if present, indicates the date of the oldest
 *                            configuration to be updated.
 * @param p_config_end_date   Optional, if present, indicates the date of the newest
 *                            configuration to be updated.
 */

PROCEDURE upgrade_configs_by_items_cp
       (errbuf              OUT NOCOPY VARCHAR2
       ,retcode             OUT NOCOPY NUMBER
       ,p_organization_code IN VARCHAR2
       ,p_organization_id   IN NUMBER
       ,p_top_inv_item_from IN VARCHAR2
       ,p_top_inv_item_to   IN VARCHAR2
       ,p_application_id    IN NUMBER
       ,p_config_begin_date IN VARCHAR2
       ,p_config_end_date   IN VARCHAR2
       );
---------------------------------------------------------------------------------------
/*
 * Concurrent procedure for Configuration Upgrade by Product key.
 * @param errbuf              Standard Oracle Concurrent Program output parameters.
 * @param retcode             Standard Oracle Concurrent Program output parameters.
 * @param p_product_key       Used to search configurations, required.
 * @param p_application_id    Used to refine search for equivalent published models
 *                            to use as baselines for upgrade, optional.
 * @param p_config_begin_date Optional, if present, indicates the date of the oldest
 *                            configuration to be updated.
 * @param p_config_end_date   Optional, if present, indicates the date of the newest
 *                            configuration to be updated.
 */

PROCEDURE upgrade_configs_by_product_cp
       (errbuf               OUT NOCOPY VARCHAR2
       ,retcode              OUT NOCOPY NUMBER
       ,p_product_key        IN VARCHAR2
       ,p_application_id     IN NUMBER
       ,p_config_begin_date  IN VARCHAR2
       ,p_config_end_date    IN VARCHAR2
       );
---------------------------------------------------------------------------------------
/*
 * This procedure converts a publication target to a Development Instance.
 * @param errbuf       Standard Oracle Concurrent Program output parameters.
 * @param retcode      Standard Oracle Concurrent Program output parameters.
 */

PROCEDURE convert_instance_cp(errbuf       OUT NOCOPY VARCHAR2,
                              retcode      OUT NOCOPY NUMBER
                             );
---------------------------------------------------------------------------------------
PROCEDURE obsolete_nonpublishable(p_commit_flag   IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2
                                 );

---------------------------------------------------------------------------------------
/*
 * The target machine may have been converted into a Developer enabled, migratable machine.
 * If so, the target is publishable no more.
 *
 * This method will verify for each server before, presenting to the user in a Dropdown
 * when a publication is defined in Developer.
 */

FUNCTION target_open_for (
   p_migration_or_publishing   IN   VARCHAR2,
   p_link_name                 IN   VARCHAR2,
   p_local_name                IN   VARCHAR2
)  RETURN VARCHAR2;
---------------------------------------------------------------------------------------
/*
 * For a given link name, get the converted target name.
 */

FUNCTION get_converted_target(p_link_name  IN VARCHAR2, p_instance_name IN VARCHAR2)
  RETURN VARCHAR2;
---------------------------------------------------------------------------------------
/*
 * The target machine may have been convrted into
 * a Developer enabled, migratable machine.
 * If so, the target is publishable no more
 */

FUNCTION get_target_name_if_converted RETURN t_varchar40_array_tbl_type;
---------------------------------------------------------------------------------------
END;

 

/
