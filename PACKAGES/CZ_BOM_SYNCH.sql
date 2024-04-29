--------------------------------------------------------
--  DDL for Package CZ_BOM_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_BOM_SYNCH" AUTHID CURRENT_USER AS
/*	$Header: czbomsys.pls 120.5 2006/08/09 15:43:17 asiaston ship $		*/
---------------------------------------------------------------------------------------
  THIS_PACKAGE_NAME              CONSTANT VARCHAR2(25) := 'CZ_BOM_SYNCH';
  THIS_FILE_NAME                 CONSTANT VARCHAR2(25) := 'czbomsyb.pls';
  THIS_HEADER_TAG                CONSTANT VARCHAR2(25) := '%$Header%';
  THIS_DATE_FORMAT               CONSTANT VARCHAR2(25) := 'YYYY/MM/DD/HH24:MI:SS';
---------------------------------------------------------------------------------------
  ORACLE_YES                     CONSTANT PLS_INTEGER  := 1;
  ORACLE_NO                      CONSTANT PLS_INTEGER  := 2;
  CONCURRENT_SUCCESS             CONSTANT PLS_INTEGER  := 0;
  CONCURRENT_ERROR               CONSTANT PLS_INTEGER  := 2;
  ORACLE_BOM_MODEL               CONSTANT PLS_INTEGER  := 1;
  ORACLE_BOM_OPTIONCLASS         CONSTANT PLS_INTEGER  := 2;
  ORACLE_BOM_STANDARD            CONSTANT PLS_INTEGER  := 4;
  DEFAULT_COMMIT_BLOCK_SIZE      CONSTANT PLS_INTEGER  := 500;
  LOCAL_SERVER_SEED_ID           CONSTANT PLS_INTEGER  := 0;
  DEFAULT_DAYSTILLEPOCHEND       CONSTANT PLS_INTEGER  := 20000;
---------------------------------------------------------------------------------------
  STRING_HASH_BASE_VALUE         CONSTANT NUMBER       := 1000;
  STRING_HASH_SIZE               CONSTANT NUMBER       := 1048576; -- 2 ** 20
  STRING_CONCAT_CHARACTER        CONSTANT VARCHAR2(1)  := '-';
---------------------------------------------------------------------------------------
  EpochBeginDate                 CONSTANT DATE         := CZ_UTILS.EPOCH_BEGIN_;
  EpochEndDate                   CONSTANT DATE         := CZ_UTILS.EPOCH_END_;
---------------------------------------------------------------------------------------
  PS_NODE_TYPE_REFERENCE         CONSTANT PLS_INTEGER  := 263;
  PS_NODE_TYPE_BOM_MODEL         CONSTANT PLS_INTEGER  := 436;
  PS_NODE_TYPE_BOM_OPTIONCLASS   CONSTANT PLS_INTEGER  := 437;
  PS_NODE_TYPE_BOM_STANDARD      CONSTANT PLS_INTEGER  := 438;
---------------------------------------------------------------------------------------
  EXECUTION_MODE_REPORT          CONSTANT PLS_INTEGER  := 0;
  EXECUTION_MODE_VERIFY          CONSTANT PLS_INTEGER  := 1;
  EXECUTION_MODE_SYNC            CONSTANT PLS_INTEGER  := 2;
---------------------------------------------------------------------------------------
  URGENCY_ERROR                  CONSTANT PLS_INTEGER  := 0;
  URGENCY_WARNING                CONSTANT PLS_INTEGER  := 1;
  URGENCY_MESSAGE                CONSTANT PLS_INTEGER  := 2;
  URGENCY_DEBUG                  CONSTANT PLS_INTEGER  := 3;
---------------------------------------------------------------------------------------
  LOG_LEVEL_WARNINGS             CONSTANT PLS_INTEGER  := 0;
  LOG_LEVEL_MESSAGES             CONSTANT PLS_INTEGER  := 1;
  LOG_LEVEL_DEBUG                CONSTANT PLS_INTEGER  := 2;
---------------------------------------------------------------------------------------
  ERROR_FLAG_SUCCESS             CONSTANT VARCHAR2(1)  := '0';
  ERROR_FLAG_ERROR               CONSTANT VARCHAR2(1)  := '1';
---------------------------------------------------------------------------------------
  FLAG_NOT_DELETED               CONSTANT VARCHAR2(1)  := '0';
  FLAG_BOM_OPTIONAL              CONSTANT VARCHAR2(1)  := '0';
  FLAG_BOM_REQUIRED              CONSTANT VARCHAR2(1)  := '1';
---------------------------------------------------------------------------------------
  ORIGINAL_SEPARATOR             CONSTANT VARCHAR2(1)  := ':';
  NAME_PATH_SEPARATOR            CONSTANT VARCHAR2(2)  := '=>';
---------------------------------------------------------------------------------------
  PUBLICATION_STATUS_PROCESSING  CONSTANT VARCHAR2(3)  := 'PRC';
  PUBLICATION_STATUS_OK          CONSTANT VARCHAR2(3)  := 'OK';
  PUBLICATION_TARGET_FLAG        CONSTANT VARCHAR2(1)  := 'T';
  REPOSITORY_TYPE_PROJECT        CONSTANT VARCHAR2(3)  := 'PRJ';
  FND_LANGUAGES_BASE             CONSTANT VARCHAR2(1)  := 'B';
  FND_LANGUAGES_INSTALLED        CONSTANT VARCHAR2(1)  := 'I';
---------------------------------------------------------------------------------------
  DBSETTINGS_SECTION_NAME        CONSTANT VARCHAR2(25) := 'BOMSYNCH';
  COMMIT_BLOCK_SETTING_ID        CONSTANT VARCHAR2(25) := 'COMMITBLOCKSIZE';
  VERIFY_PROPERTIES_SETTING_ID   CONSTANT VARCHAR2(25) := 'VERIFYITEMPROPERTIES';
  DAYSTILLEPOCHEND_SETTING_ID    CONSTANT VARCHAR2(25) := 'DAYSTILLEPOCHEND';
---------------------------------------------------------------------------------------
  CZ_SYNC_UNEXPECTED_STRUCTURE   EXCEPTION;
  CZ_SYNC_UNABLE_TO_REPORT       EXCEPTION;
  CZ_SYNC_GENERAL_EXCEPTION      EXCEPTION;
  CZ_SYNC_NO_DATABASE_LINK       EXCEPTION;
  CZ_SYNC_INCORRECT_MODEL        EXCEPTION;
  CZ_SYNC_NO_ORGANIZATION_ID     EXCEPTION;
  CZ_SYNC_NORMAL_EXCEPTION       EXCEPTION;
---------------------------------------------------------------------------------------
  PROCEDURE synchronize_all_models_cp(errbuf        OUT NOCOPY VARCHAR2,
                                      retcode       OUT NOCOPY NUMBER,
                                      p_target_name IN  VARCHAR2);
---------------------------------------------------------------------------------------
  PROCEDURE report_model_cp(errbuf        OUT NOCOPY VARCHAR2,
                            retcode       OUT NOCOPY NUMBER,
                            p_target_name IN  VARCHAR2,
                            p_model_id    IN  NUMBER);
---------------------------------------------------------------------------------------
  PROCEDURE report_all_models_cp(errbuf        OUT NOCOPY VARCHAR2,
                                 retcode       OUT NOCOPY NUMBER,
                                 p_target_name IN  VARCHAR2);
---------------------------------------------------------------------------------------
  PROCEDURE verify_model(p_model_id    IN  NUMBER,
                         p_target_name IN  VARCHAR2,
                         p_error_flag  IN OUT NOCOPY VARCHAR2,
                         p_run_id      IN OUT NOCOPY NUMBER);
---------------------------------------------------------------------------------------
  PROCEDURE build_structure_map(p_model_id       IN NUMBER,
                                p_target_name    IN VARCHAR2,
                                p_execution_mode IN NUMBER,
                                p_log_level      IN NUMBER,
                                p_error_flag     IN OUT NOCOPY VARCHAR2,
                                p_run_id         IN OUT NOCOPY NUMBER);
---------------------------------------------------------------------------------------
  FUNCTION psnode_origSysRef(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION psnode_compSeqPath(p_component_seq_path IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION psnode_compSeqId(p_component_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION itemMaster_origSysRef(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION itemType_origSysRef(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION devlProject_origSysRef(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION locText_origSysRef(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION projectBill_orgId(p_organization_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION projectBill_topItemId(p_top_item_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION projectBill_compItemId(p_component_item_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION projectBill_sourceServer(p_server_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION modelPublication_productKey(p_product_key IN VARCHAR2)
    RETURN VARCHAR2;
---------------------------------------------------------------------------------------
  FUNCTION modelPublication_topItemId(p_top_item_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
  FUNCTION modelPublication_orgId(p_organization_id IN NUMBER)
    RETURN NUMBER;
---------------------------------------------------------------------------------------
FUNCTION devlProject_invId(p_inventory_item_id IN NUMBER)
  RETURN NUMBER;
------------------------------------------------------------------------------
FUNCTION devlProject_orgId(p_organization_id IN NUMBER)
  RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION devlProject_productKey(p_product_key IN VARCHAR2)
  RETURN VARCHAR2;
------------------------------------------------------------------------

FUNCTION ITEMPROPVALUES_ORIGSYSREF(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;
------------------------------------------------------------------------

FUNCTION ITEMTYPEPROP_ORIGSYSREF(p_orig_sys_ref IN VARCHAR2)
    RETURN VARCHAR2;


END;

 

/
