--------------------------------------------------------
--  DDL for Package EC_MAPPING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_MAPPING_UTILS" AUTHID CURRENT_USER AS
-- $Header: ECMAPUTS.pls 120.3 2005/09/29 10:50:12 arsriniv ship $

   FUNCTION ec_get_map_id(
      xMapCode                   IN ece_mappings.map_code%TYPE,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;

   FUNCTION ec_get_map_code(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N') RETURN ece_mappings.map_code%TYPE;

   FUNCTION ec_get_upgrade_map_id(
      xMap_ID                    IN NUMBER) RETURN NUMBER;

   FUNCTION ec_get_main_map_id(
      xMap_ID                    NUMBER) RETURN NUMBER;

   FUNCTION ec_get_trans_upgrade_status(
      xTransactionType           IN ece_interface_tables.transaction_type%TYPE,
      iMapId 	                  IN ece_interface_tables.map_id%TYPE) RETURN VARCHAR2;

   FUNCTION ec_get_trans_upgrade_status(
      xTransactionType           IN ece_interface_tables.transaction_type%TYPE) RETURN VARCHAR2;

   PROCEDURE ec_upgrade_column_rules(
      xInterface_Column_ID_Main  IN NUMBER,
      xInterface_Column_ID_Upg   IN NUMBER);

   PROCEDURE ec_upgrade_layout(
      xMap_ID_Upg                IN NUMBER,
      xUpgrade_Column_Rules_Flag IN VARCHAR2,
      xUpgrade_Code_Cat_Flag     IN VARCHAR2);

   PROCEDURE ec_upgrade_process_rules(
      xMap_ID                    IN NUMBER); --Upgrade Table Map_ID

   PROCEDURE ec_copy_column_rules(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_dynamic_actions(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_external_levels(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_interface_columns(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_interface_tables(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_level_matrices(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_mappings(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_process_rules(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_map_data_by_mapcode(
      xMapCode                   IN ece_mappings.map_code%TYPE);

   PROCEDURE ec_copy_map_data_by_mapid(
      xMap_ID                    IN NUMBER);

   PROCEDURE ec_copy_map_data_by_trans(
      xTransactionType           IN ece_interface_tables.transaction_type%TYPE,
      xMapType                   IN ece_mappings.map_type%TYPE);

   PROCEDURE ec_delete_column_rules(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_dynamic_action(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_external_levels(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_interface_columns(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_interface_tables(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_level_matrices(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_mappings(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_process_rules(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_map_data_by_mapcode(
      xMapCode                   IN ece_mappings.map_code%TYPE,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_map_data_by_mapid(
      xMap_ID                    IN NUMBER,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_delete_map_data_by_trans(
      xTransactionType           IN ece_interface_tables.transaction_type%TYPE,
      xMapType                   IN ece_mappings.map_type%TYPE,
      xUpgradeFlag               IN VARCHAR2 DEFAULT 'N');

   PROCEDURE ec_migrate_map_to_production(
      xMapCode                   IN ece_mappings.map_code%TYPE,
      xTransExists               IN BOOLEAN);

   PROCEDURE ec_reconcile_seed(
      errbuf                     OUT NOCOPY   VARCHAR2,
      retcode                    OUT NOCOPY  VARCHAR2,
      transaction_type           IN    VARCHAR2,
      preserve_layout            IN    VARCHAR2,
      preserve_proc_rules        IN    VARCHAR2,
      preserve_col_rules         IN    VARCHAR2,
      preserve_cc_cat            IN    VARCHAR2,
      v_debug_mode               IN    NUMBER DEFAULT 3);

   PROCEDURE ec_remap_tp_details(
      xMap_ID                    IN NUMBER); --Upgrade Table Map_ID

END;


 

/
