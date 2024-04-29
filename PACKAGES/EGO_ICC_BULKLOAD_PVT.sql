--------------------------------------------------------
--  DDL for Package EGO_ICC_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ICC_BULKLOAD_PVT" AUTHID CURRENT_USER AS
 /* $Header: EGOVICCS.pls 120.0.12010000.4 2010/06/11 12:24:50 kjonnala noship $ */

   ---
   --- global variables for error handling and processing
   ---
   ---
   G_BO_IDENTIFIER_ICC      CONSTANT VARCHAR2(30) := 'ICC';

   --- Flow Type decides if the calling program
   --- is a concurrent program or the API being invoked directly
   ---
   G_EGO_MD_INTF  CONSTANT NUMBER := 1;
   G_EGO_MD_API   CONSTANT NUMBER := 2;
   G_FLOW_TYPE    NUMBER(1) := G_EGO_MD_API;

   G_ENTITY_ICC_HEADER             CONSTANT  VARCHAR2(30) := 'ICC_HEADER';
   G_ENTITY_ICC_VERSION            CONSTANT  VARCHAR2(30) := 'ICC_VERSIONS';
   G_ENTITY_ICC_AG_ASSOC           CONSTANT  VARCHAR2(30) := 'AG_ASSOCS';
   G_ENTITY_ICC_FN_ASSOC           CONSTANT  VARCHAR2(30) := 'ICC_FUNCTIONS';
   G_ENTITY_ICC_FN_PARAM_MAP       CONSTANT  VARCHAR2(30) := 'FN_PARAM_MAPS';
   G_ENTITY_ICC_LOCK               CONSTANT  VARCHAR2(30) := 'EGO_ITEM_CATALOG_CATEGORY';

   G_ENTITY_ICC_HEADER_TAB          CONSTANT  VARCHAR2(30) := 'MTL_ITEM_CAT_GRPS_INTERFACE';
   G_ENTITY_ICC_VERS_TAB            CONSTANT VARCHAR2(30) := 'EGO_ICC_VERS_INTERFACE';
   G_ENTITY_ICC_AG_ASSOC_TAB        CONSTANT VARCHAR2(30) := 'EGO_ATTR_GRPS_ASSOC_INTERFACE';
   G_ENTITY_FUNC_PARAM_MAP_TAB      CONSTANT VARCHAR2(30) := 'EGO_FUNC_PARAMS_MAP_INTERFACE';


   --- Default values used for processing
   ---
   G_DEFAULT_USER_NAME      VARCHAR2(10) := 'MFG';
   G_ITEM_CAT_KFF_APPL      VARCHAR2(5) := 'INV';
   G_STRUCTURE_NUMBER       NUMBER     := 101;
   G_ICC_KFF_NAME           VARCHAR2(4) := 'MICG';
   G_INV_SCHEMA             VARCHAR2(3) := 'INV';

   G_ITEM_OBJ_NAME          VARCHAR2(10) := 'EGO_ITEM';
   G_SEEDED_AG_TYPE         VARCHAR2(17) := 'EGO_MASTER_ITEMS';
   G_APPL_NAME              VARCHAR2(3) := 'EGO';
   G_EGO_APPL_ID            NUMBER := NULL;    --- assigned at run time

   G_NUM_GEN_FUNCTION       VARCHAR2(20) := 'NUMBER_GENERATION'   ;
   G_DESC_GEN_FUNCTION      VARCHAR2(20) := 'DESC_GENERATION'   ;
   G_P4TP_PROFILE_ENABLED    BOOLEAN      :=  FALSE;

   ---
   ---    global variables for use across the entity validations
   ---
   G_TTYPE_CREATE CONSTANT VARCHAR2(10) := 'CREATE';
   G_TTYPE_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';
   G_TTYPE_SYNC CONSTANT   VARCHAR2(10)   := 'SYNC';
   G_TTYPE_DELETE CONSTANT VARCHAR2(10) := 'DELETE';


   ----
   ---- Process codes for API, which will be updated to the interface table
   ----
   G_PROCESS_STATUS_INITIAL  CONSTANT NUMBER(1) := 1;    -- Initial and post validation phase
   G_PROCESS_STATUS_SUCCESS  CONSTANT NUMBER(1) := 7;   -- Successfuly processed
   G_PROCESS_STATUS_ERROR    CONSTANT NUMBER(1) := 3;     -- Error


   G_TYPE_ERROR CONSTANT VARCHAR2(1):= 'E';
   G_TYPE_WARNING CONSTANT VARCHAR2(1):= 'W';

   G_PROCESS_STATUS_WARNING CONSTANT NUMBER(1) := 5; -- Check

   G_PKG_NAME    CONSTANT VARCHAR2(30) := 'EGO_ICC_BULKLOAD_PVT';


    /*  API return status

      G_RET_STS_SUCCESS means that the API was successful in performing
      all the operation requested by its caller.

      G_RET_STS_ERROR means that the API failed to perform one or more
      of the operations requested by its caller.

      G_RET_STS_UNEXP_ERROR means that the API was not able to perform
      any of the operations requested by its callers because of an
      unexpected error.

    */

    G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

    --- WHO columns
    ---
    G_CONC_REQUEST_ID       CONSTANT    FND_CONCURRENT_REQUESTS.REQUEST_ID%TYPE  := FND_GLOBAL.CONC_REQUEST_ID;
    G_USER_ID               CONSTANT    FND_USER.USER_ID%type := FND_GLOBAL.USER_ID;
    G_LOGIN_ID              CONSTANT    FND_USER.last_update_login%type := FND_GLOBAL.LOGIN_ID;
    G_PROG_APPL_ID          CONSTANT    NUMBER := FND_GLOBAL.PROG_APPL_ID;
    G_PROGRAM_ID            CONSTANT    NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;



    --- Processing related columns
    ---
    G_SET_PROCESS_ID        NUMBER(15) := NULL;

    G_PARTY_ID              EGO_USER_V.party_id%TYPE;
    G_MISS_NUM              CONSTANT NUMBER := FND_API.G_NULL_NUM;
    G_MISS_CHAR             CONSTANT VARCHAR2(1) := FND_API.G_NULL_CHAR;
    G_MISS_DATE             CONSTANT DATE        := FND_API.G_NULL_DATE;
    G_MAX_FETCH_SIZE        CONSTANT NUMBER := 2000;

    --- Record and table datatypes used for the entity processing
    ---

    -- Record Types
    SUBTYPE ego_icc_rec_type is EGO_METADATA_PUB.ego_icc_rec_type;

    SUBTYPE ego_ag_assoc_rec_type is EGO_METADATA_PUB.ego_ag_assoc_rec_type;

    SUBTYPE ego_func_param_map_rec_type is EGO_METADATA_PUB.ego_func_param_map_rec_type;

    SUBTYPE ego_icc_vers_rec_type is EGO_METADATA_PUB.ego_icc_vers_rec_type;

    --- Table types
    SUBTYPE ego_icc_tbl_type is EGO_METADATA_PUB.ego_icc_tbl_type;

    SUBTYPE ego_ag_assoc_tbl_type is EGO_METADATA_PUB.ego_ag_assoc_tbl_type  ;

    SUBTYPE ego_func_param_map_tbl_type is EGO_METADATA_PUB.ego_func_param_map_tbl_type  ;

    SUBTYPE ego_icc_vers_tbl_type is EGO_METADATA_PUB.ego_icc_vers_tbl_type  ;







    --- package level NULL varaibles used for defaulting
    ---
    g_null_icc_rec         ego_icc_rec_type;
    g_null_ag_assoc_rec    ego_ag_assoc_rec_type;
    g_null_func_params_rec ego_func_param_map_rec_type;
    g_null_icc_vers_rec    ego_icc_vers_rec_type;




    g_null_icc_tbl            ego_icc_tbl_type;
    g_null_ag_assoc_tbl       ego_ag_assoc_tbl_type;
    g_null_func_param_map_tbl ego_func_param_map_tbl_type;
    g_null_icc_vers_tbl       ego_icc_vers_tbl_type;



   /*
    * This procedure reads the records from the ICC related
    * interface tables, validate and then process the records
    */


   PROCEDURE Import_ICC_Intf
    (
       p_set_process_id            IN  NUMBER
    ,  x_return_status             OUT NOCOPY VARCHAR2
    ,  x_return_msg                OUT NOCOPY VARCHAR2
    );


    /*
     * This function takes the Concatenated ICC name and returns the ICC ID
     * if the operation is FIND_COMBINATION
     * For operation CHECK_SEGMENTS , returns 1 if combination exists else returns 0
     */


    FUNCTION Get_Catalog_Group_Id (  p_catalog_group_name    IN VARCHAR2
                                   , p_operation         IN VARCHAR2
                                  )
    RETURN NUMBER;


    /*
    * This procedure deletes the successfully processed records from the interface tables
    *
    */

    PROCEDURE Delete_Processed_ICC (  p_set_process_id  IN NUMBER
                                   ,  x_return_status    OUT NOCOPY VARCHAR2
                                   ,  x_return_msg       OUT NOCOPY VARCHAR2
                                   );

  /* Exposed for dependency in package body
   * not for public use
   */
  PROCEDURE Construct_Colltn_And_Validate (  p_entity IN VARCHAR2
                                           ,p_icc_name IN VARCHAR2 DEFAULT NULL    --- Used by version processing
                                           ,p_icc_id   IN NUMBER DEFAULT NULL    --- Used by version processing
                                           ,x_return_status OUT NOCOPY VARCHAR2
                                           ,x_return_msg  OUT NOCOPY VARCHAR2
                                         );




 END EGO_ICC_BULKLOAD_PVT;

/
